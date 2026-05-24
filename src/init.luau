--!optimize 2
local cleanup = require("@self/cleanup")
local events = require("@self/events")
local vdom = require("@self/vdom")
local widget_registrar = require("@self/widget_registrar")

-- checkbox
-- label
-- table
-- widget
-- arrow
-- wireframe
-- plot

export type Serde<T> = widget_registrar.Serde<T>

export type function Combine(root: type, a: type, b: type, c: type, d: type, e: type, f: type, g: type)
	local function annoying(root: type, ...: type)
		assert(root.tag == "table")
		local copy = types.copy(root)

		for i = 1, select("#", ...) do
			local t: type = select(i, ...)
			if t.tag ~= "table" then
				continue
			end

			for key, value in t:properties() do
				copy:setreadproperty(key, value.read)
				copy:setwriteproperty(key, value.write)
			end
		end

		return copy
	end

	return annoying(root, a)
end

-- we maintain a sparse set internally
local dense_count = 0
local map_node_to_dense: { [vdom.Node]: number } = {}
local map_dense_to_node: { [number]: vdom.Node } = {}
local map_dense_to_emitted: { [number]: Instance } = {}
local map_dense_to_dumpster: { [number]: { unknown } } = {}
local map_dense_to_props_updated: { [number]: (unknown) -> () } = {}

local function remove_node(node: vdom.Node)
	for _, child in node.children do
		remove_node(child)
	end

	local dense = map_node_to_dense[node]
	local last = dense_count
	local last_node = map_dense_to_node[last]

	cleanup(map_dense_to_dumpster[dense])

	map_dense_to_node[dense] = map_dense_to_node[last]
	map_dense_to_emitted[dense] = map_dense_to_emitted[last]
	map_dense_to_dumpster[dense] = map_dense_to_dumpster[last]
	map_dense_to_props_updated[dense] = map_dense_to_props_updated[last]
	map_node_to_dense[last_node] = dense

	map_dense_to_emitted[last] = nil
	map_dense_to_dumpster[last] = nil
	map_dense_to_node[last] = nil
	map_dense_to_props_updated[last] = nil
	map_node_to_dense[node] = nil

	dense_count -= 1
end

local callback_functions: vdom.NodeCallbacks = {
	created = function(parent, child, key)
		dense_count += 1

		local widget = widget_registrar.get(child.type)
		local dense = dense_count
		local dense_parent = map_node_to_dense[parent]

		local function on_updated_props(callback)
			local dense = map_node_to_dense[child]
			map_dense_to_props_updated[dense] = callback
		end

		local function cleanup(value)
			local dense = map_node_to_dense[child]
			table.insert(map_dense_to_dumpster[dense], value)
		end

		local scope = { key = key, cleanup = cleanup, on_updated_props = on_updated_props }

		map_node_to_dense[child] = dense
		map_dense_to_node[dense] = child
		map_dense_to_dumpster[dense] = {}

		local emitted =
			widget.emit(scope :: any, events.client(child, widget.events_template), map_dense_to_emitted[dense_parent])
		map_dense_to_emitted[dense] = emitted
	end,
	destroyed = function(parent, child, key)
		remove_node(child)
		parent.children[key] = nil
	end,
	fire_event = function(node, event_idx, data)
		warn("todo implement events on client")
	end,
	apply_update = function(node, delta_props)
		local widget = widget_registrar.get(node.type)
		node.props = widget.serde.read(delta_props, node.props)
	end,
	props_updated = function(node)
		local dense = map_node_to_dense[node]
		local update = map_dense_to_props_updated[dense]

		if update then
			update(node.props)
		end
	end,
}

-- api

local nx = {}

nx.widget = widget_registrar.register
nx.empty_serde = {
	read = function()
		return nil
	end,
	write = function()
		return nil
	end,
} :: Serde<nil>

function nx.target(parent: Instance)
	local root: vdom.Node = { type = "vdom", props = nil, state = false, children = {} }
	dense_count += 1

	local dense = dense_count

	map_node_to_dense[root] = dense
	map_dense_to_node[dense] = root
	map_dense_to_dumpster[dense] = {}
	map_dense_to_props_updated[dense] = function() end
	map_dense_to_emitted[dense] = parent

	return root
end

-- function nx.get_diff_full(scope: widget_registrar.WriteScopeBase): vdom.NodeDiff
-- 	assert(scope.parent.type == "vdom", "cannot get diff of a node that isn't the vdom")
-- end

function nx.get_diff_delta(scope: widget_registrar.WriteScopeBase): vdom.NodeDiff?
	assert(scope.parent.type == "vdom", "cannot get diff of a node that isn't the vdom")

	debug.profilebegin("generate diff delta")
	local diff = scope.parent_diff
	scope.parent_diff = {
		children = {},
	}

	local is_diff = vdom.fix(scope.parent, diff)
	debug.profileend()

	return if is_diff then diff else nil
end

function nx.apply_diff(target: vdom.Node, diff: vdom.NodeDiff?)
	if not diff then
		return
	end

	debug.profilebegin("apply diff")
	vdom.apply_diff(target, target, diff, "", callback_functions)
	debug.profileend()
end

function nx.get_client_fired_events(target: vdom.Node)
	return vdom.collect_state_as_events(target)
end

function nx.set_client_fired_events(root: widget_registrar.WriteScopeBase, diff: vdom.NodeDiff?)
	root.incoming_diff = diff
end

nx.event = events.event

nx.scope = function(main, ...)
	local root: vdom.Node = { type = "vdom", props = nil, state = false, children = {} }
	local diff: vdom.NodeDiff = { children = {} }

	local scope: widget_registrar.WriteScopeBase = { parent = root, parent_diff = diff } :: any
	local index_mt = table.clone(main)

	for i = 1, select("#", ...) do
		for key, value in select(i, ...) do
			index_mt[key] = value
		end
	end

	return setmetatable(scope, { __index = index_mt }) :: any
end :: <A, B, C, D, E, F, G>(
	A,
	B?,
	C?,
	D?,
	E?,
	F?,
	G?
) -> Combine<widget_registrar.WriteScopeBase, A, B, C, D, E, F, G>

return nx
