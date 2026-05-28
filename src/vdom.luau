--!optimize 2
local vdom = {}

export type Node = {
	type: string,
	props: unknown,
	state: { unknown } | false,
	count: number,

	children: { [string]: Node? },
}

export type NodeDiff = {
	type: string?,
	props: unknown,
	events: { [number]: unknown }?,
	count: number?,

	children: { [string]: NodeDiff? }?,
}

local internal_node_count = 0
function vdom.create_node(parent: Node, parent_diff: NodeDiff, type: string, key: string): (Node, NodeDiff)
	assert(parent_diff.children, "missing children for parent diff")

	local node = parent.children[key]
	local diff: NodeDiff = {
		children = {},
	}

	if node and node.type ~= type or node == nil then
		parent_diff.children[key] = diff
		diff.type = type
		diff.count = internal_node_count

		node = {
			type = type,
			events = nil,
			state = false,
			children = {},
			count = internal_node_count,
		} :: Node
		internal_node_count += 1
		parent.children[key] = node
	elseif node ~= nil then
		parent_diff.children[key] = diff
		parent.children[key] = node
	else
		error(`unhandled case`)
	end

	assert(node, "missing node")

	return node, diff
end

function vdom.remove_node(parent: Node, parent_diff: NodeDiff, key: string)
	assert(parent_diff.children, "missing children for parent diff")
	parent_diff.children[key] = {}
	parent.children[key] = nil
end

export type NodeCallbacks = {
	destroyed: (parent: Node, child: Node, key: string) -> (),
	created: (parent: Node, child: Node, key: string) -> (),
	fire_event: (node: Node, event_idx: number, data: unknown) -> (),
	-- new_props should update the props and apply the delta
	apply_update: (node: Node, delta_props: unknown) -> (),
	-- props_updated should be invoked after new_props
	props_updated: (node: Node) -> (),
}

function vdom.apply_diff(parent: Node, node: Node?, diff: NodeDiff, key: string, callbacks: NodeCallbacks)
	if node == nil and diff.children == nil then
		error("wtf")
	end

	if parent == node then
		-- only root nodes can self reference themselves. changing their type is not supported
		assert(diff.type == nil, "cannot change type of root node")
	end

	-- when the type changes, all children should get deleted with it
	if diff.type and node then
		callbacks.destroyed(parent, node, key)

		node.type = diff.type
		node.children = {}

		callbacks.apply_update(node, diff.props)
		callbacks.created(parent, node, key)
		callbacks.props_updated(node)
	end

	if diff.props and node and diff.type == nil then
		callbacks.apply_update(node, diff.props)
		callbacks.props_updated(node)
	end

	if node == nil then
		assert(diff.type, "attempt to modify node that has no type")
		assert(diff.count, "attempt to modify node that has no count")

		node = {
			type = diff.type,
			props = nil,
			state = false,
			count = diff.count,

			children = {},
		} :: Node

		parent.children[key] = node

		assert(node)
		callbacks.apply_update(node, diff.props)
		callbacks.created(parent, node :: Node, key)
		callbacks.props_updated(node)
	end

	if diff.count and node then
		node.count = diff.count
	end

	-- children mounted
	if diff.children then
		assert(node, "missing node")

		for key, child_diff in diff.children do
			vdom.apply_diff(node, node.children[key], child_diff, key, callbacks)
		end
	elseif node then -- destroy node, no children = destroy indicator
		callbacks.destroyed(parent, node, key)
		parent.children[key] = nil
		return
	else
		return
	end

	if diff.events and node then
		for idx, value in diff.events do
			callbacks.fire_event(node, idx, value)
		end
	end
end

function vdom.generate_diff(node: Node, generate_props_delta: (Node) -> unknown)
	local diff: NodeDiff = {
		type = node.type,
		props = generate_props_delta(node),
		count = node.count,

		children = {},
	}
	assert(diff.children)

	for key, child in node.children do
		diff.children[key] = vdom.generate_diff(child, generate_props_delta)
	end

	return diff
end

local EMPTY: NodeDiff = {}
table.freeze(EMPTY)

-- finds removed nodes
function vdom.fix(node: Node?, diff: NodeDiff)
	if node == nil then
		return true
	end

	local can_exist = if diff.events or diff.props or diff.type or diff.children == nil then true else false

	if diff.children then
		for key, value in node.children do
			if diff.children[key] == nil then
				node.children[key] = nil
				diff.children[key] = EMPTY :: NodeDiff
				can_exist = true
			end
		end

		for key, value in diff.children do
			if value == EMPTY then
				continue
			elseif vdom.fix(node.children[key], value) then
				can_exist = true
			else
				diff.children[key] = nil
			end
		end
	end

	return can_exist
end

function vdom.collect_state_as_events(node: Node): NodeDiff?
	local diff: NodeDiff = { children = {} }
	assert(diff.children)

	if node.state then
		diff.events = node.state
		node.state = false
	end

	for key, child in node.children do
		diff.children[key] = vdom.collect_state_as_events(child)
	end

	if next(diff.children) == nil and diff.events == nil then
		return nil
	end

	return diff
end

do
	local at = 0
	local at_unknown = 0
	local out = buffer.create(2 ^ 18)
	local out_unknown: { any } = {}

	local function process(node: NodeDiff)
		local flags = 0b0000

		flags += if node.children then 0b10000 else 0b00000
		flags += if node.events then 0b01000 else 0b00000
		flags += if node.props then 0b00100 else 0b00000
		flags += if node.type then 0b00010 else 0b00000
		flags += if node.count then 0b00001 else 0b00000

		buffer.writeu8(out, at, flags)
		at += 1

		if node.type then
			local size = #node.type
			buffer.writeu8(out, at, size)
			buffer.writestring(out, at + 1, node.type)
			at += size + 1
		end

		if node.events then
			local n = 0
			for _ in node.events do
				n += 1
			end

			buffer.writeu8(out, at, n)
			at += 1

			for idx, event in node.events do
				buffer.writeu8(out, at, idx)
				at += 1
				at_unknown += 1
				out_unknown[at_unknown] = event
			end
		end

		if node.props then
			at_unknown += 1
			out_unknown[at_unknown] = node.props
		end

		if node.count then
			buffer.writeu32(out, at, node.count)
			at += 4
		end

		if node.children then
			local n = 0
			for _ in node.children do
				n += 1
			end

			buffer.writeu16(out, at, n)
			at += 2

			for key, child in node.children do
				local size = #key
				buffer.writeu8(out, at, size)
				buffer.writestring(out, at + 1, key)
				at += size + 1

				process(child)
			end
		end
	end

	--[=[
	Compresses the node diff into a buffer and unknown list, which can be sent over the network.
	]=]
	function vdom.compress(node: NodeDiff): (buffer, { unknown })
		process(node)

		local b = buffer.create(at)
		local copy = table.create(at_unknown)

		buffer.copy(b, 0, out, 0, at)
		table.move(out_unknown, 1, at_unknown, 1, copy)

		table.clear(out_unknown)

		at = 0
		at_unknown = 0

		return b, copy
	end
end

do
	local at = 0
	local at_unknown = 1
	local in_b = buffer.create(2 ^ 16)
	local in_unknown: { any } = {}

	local function process(): NodeDiff
		local flags = buffer.readu8(in_b, at)
		at += 1

		local has_children = bit32.btest(flags, 0b10000)
		local has_events = bit32.btest(flags, 0b01000)
		local has_props = bit32.btest(flags, 0b00100)
		local has_type = bit32.btest(flags, 0b00010)
		local has_count = bit32.btest(flags, 0b00001)

		local type: string?
		local children: { [string]: NodeDiff? }?
		local events: { [number]: unknown }?
		local props: unknown?
		local count: number?

		if has_type then
			local size = buffer.readu8(in_b, at)
			type = buffer.readstring(in_b, at + 1, size)
			at += size + 1
		end

		if has_events then
			events = {}
			local total = buffer.readu8(in_b, at)
			at += 1

			for i = 0, total - 1 do
				local event_idx = buffer.readu8(in_b, at + i)
				events[event_idx] = in_unknown[at_unknown]
				at_unknown += 1
			end

			at += total
		end

		if has_props then
			props = in_unknown[at_unknown]
			at_unknown += 1
		end

		if has_count then
			count = buffer.readu32(in_b, at)
			at += 4
		end

		if has_children then
			children = {}
			local total = buffer.readu16(in_b, at)
			at += 2

			for i = 1, total do
				local key_size = buffer.readu8(in_b, at)
				local key = buffer.readstring(in_b, at + 1, key_size)
				at += key_size + 1
				children[key] = process()
			end
		end

		return {
			type = type,
			children = children,
			events = events,
			props = props,
			count = count,
		}
	end

	--[=[
	Decompresses the provided buffer and unknowns list into a node diff.
	]=]
	function vdom.decompress(b: buffer, unknown: { unknown }): NodeDiff
		at = 0
		at_unknown = 1
		in_b = b
		in_unknown = unknown

		local diff = process()
		in_b = buffer.create(0)
		in_unknown = {}

		return diff
	end
end

return vdom
