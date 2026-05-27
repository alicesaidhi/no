--!optimize 2
local cleanup = require("@self/cleanup")
local events = require("@self/events")
local stylesheets = require("@self/stylesheets")
local vdom = require("@self/vdom")
local widget_registrar = require("@self/widget_registrar")
local type_fns = require(script.type_fns)

-- checkbox
-- label
-- table
-- widget
-- arrow
-- wireframe
-- plot

export type Serde<T> = widget_registrar.Serde<T>

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

	if dense == nil then
		return
	end

	if map_dense_to_dumpster[dense] then
		cleanup(map_dense_to_dumpster[dense])
	end

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

		local emitted, parent_children =
			widget.emit(scope :: any, events.client(child, widget.events_template), map_dense_to_emitted[dense_parent])
		emitted.Parent = map_dense_to_emitted[dense_parent]
		if emitted:IsA("GuiObject") then
			if emitted:IsPropertyModified("LayoutOrder") == false then
				emitted.LayoutOrder = child.count
			end
		end

		map_dense_to_emitted[dense] = parent_children or emitted
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

local no = {}

no.widget = widget_registrar.register
no.empty_serde = {
	read = function()
		return nil
	end,
	write = function()
		return nil
	end,
} :: Serde<nil>

--[=[
Creates a root node which can be used as a render target.

@param parent The instance parent where the UI should be parented under.
]=]
function no.target(parent: Instance)
	local root: vdom.Node = { type = "vdom", props = nil, state = false, children = {}, count = 0 }
	dense_count += 1

	local dense = dense_count

	map_node_to_dense[root] = dense
	map_dense_to_node[dense] = root
	map_dense_to_dumpster[dense] = {}
	map_dense_to_props_updated[dense] = function() end
	map_dense_to_emitted[dense] = parent

	stylesheets.link(parent)

	return root
end

function no.destroy_node(node: vdom.Node)
	remove_node(map_dense_to_node[dense_count])
end

function no.clear_all()
	while dense_count > 0 do
		remove_node(map_dense_to_node[dense_count])
	end
end

type WriteScopeBase = widget_registrar.WriteScopeBase

--[=[
Generates a full diff of the provided scope, which can be sent to a client connecting.

@param scope The scope for which to generate for.
]=]
function no.get_diff_full(scope: WriteScopeBase): vdom.NodeDiff
	assert(scope.parent.type == "vdom", "cannot get diff of a node that isn't the vdom")

	local children: { [string]: vdom.NodeDiff? } = {}

	for key, child in scope.parent.children do
		children[key] = vdom.generate_diff(scope.parent, function(node)
			local widget_type = widget_registrar.get(node.type)
			local result = widget_type.serde.write(node.props, nil)
			return result
		end)
	end

	return {
		children = children,
	}
end

--[=[
Generates a diff between the last time this was called and now for the provided scope,
which can be sent to a connected client.

@param scope The scope for which to generate the diff for.
]=]
function no.get_diff_delta(scope: widget_registrar.WriteScopeBase): vdom.NodeDiff?
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

--[=[
Applies a diff generated by get_diff_full or get_dill_delta and renders it on target.
This handles creating and updating the UI.

@param target A root node created by `no.target()`
@param diff A generated diff
]=]
function no.apply_diff(target: vdom.Node, diff: vdom.NodeDiff?)
	if not diff then
		return
	end

	debug.profilebegin("apply diff")
	vdom.apply_diff(target, target, diff, "", callback_functions)
	debug.profileend()
end

--[=[
Provided with a target node, collects all events and returns a diff which can be
sent back to the host to process events. This is necessary for making input work.

@param target The root node from which to collect events from.
]=]
function no.get_client_fired_events(target: vdom.Node)
	return vdom.collect_state_as_events(target)
end

--[=[
Provides event data based on the incoming diff. This diff has to be generated with
`get_client_fired_events`. Call this before doing anything with the scope.

@param root The root scope which will process the events
@param diff A diff containing events for the entire hierarchy.
]=]
function no.set_client_fired_events(root: widget_registrar.WriteScopeBase, diff: vdom.NodeDiff?)
	root.incoming_diff = diff
end

no.event = events.event
--[=[
Creates a new scope which inherits from the provided tables.
]=]
no.scope = function(main, ...)
	local root: vdom.Node = { type = "vdom", props = nil, state = false, children = {}, count = 0 }
	local diff: vdom.NodeDiff = { children = {} }

	local scope: widget_registrar.WriteScopeBase = { parent = root, parent_diff = diff } :: any
	local index_mt = table.clone(main)

	for i = 1, select("#", ...) do
		for key, value in select(i, ...) do
			index_mt[key] = value
		end
	end

	return setmetatable(scope, { __index = index_mt }) :: any, scope
end :: <A, B, C, D, E, F, G>(
	A,
	B?,
	C?,
	D?,
	E?,
	F?,
	G?
) -> (setmetatable<{}, { __index: A }>, widget_registrar.WriteScopeBase)

no.compress = vdom.compress
no.decompress = vdom.decompress

no.stylesheets = stylesheets

no.base = {
	label = require("@self/components/label"),
	header = require("@self/components/header"),
	window = require("@self/components/window"),
	button = require("@self/components/basic/button"),
	input = require("@self/components/input"),
	separator = require("@self/components/separator"),
	checkbox = require("@self/components/checkbox"),
	sameline = require("@self/components/sameline"),
	tabs = require("@self/components/tabs"),
    slider = require("@self/components/slider"),
}

return no
