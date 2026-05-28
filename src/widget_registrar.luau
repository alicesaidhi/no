--!optimize 2
local type_fns = require(script.Parent.type_fns)
local delta_compress = require("./delta_compress")
local events = require("./events")
local vdom = require("./vdom")

export type SerdeNoDiff<T> = {
	read: (diff: any) -> T,
	write: (new: T) -> any,
}

export type Serde<T> = {
	read: (diff: any, old: T) -> T,
	write: (new: T, old: T) -> any,
}

export type WriteScopeBase = {
	parent: vdom.Node,
	parent_diff: vdom.NodeDiff,
	incoming_diff: vdom.NodeDiff?,
	idx: number?,
	get_state: <T>(T?) -> (T, (T) -> ()),
}

export type EmitScopeBase<Out> = {
	key: string,

	on_updated_props: ((Out) -> ()) -> (),
	cleanup: (Instance | RBXScriptConnection | () -> ()) -> (),
}

type function ObtainNewScope(scope: type, out: type)
	if scope.tag == "table" and out.tag == "table" then
		local t = types.newtable(scope:properties())
		t:setmetatable(types.newtable({ [types.singleton("__index")] = out :: type }))
		return t
	else
		return types.intersectionof(scope, out)
	end
end

type WriteFn<Props, Events, SerdeType, Out> = (
	props: Props,
	WriteScopeBase,
	events: events.ShimToEventServer<Events>
) -> (SerdeType, Out)
type EmitFn<SerdeType, Events> = (
	EmitScopeBase<SerdeType>,
	events: events.ShimToEventClient<Events>,
	parent: Instance
) -> (Instance, Instance?)

type setmetatable_<A, B> = setmetatable<A, B>

type function Or(a: type)
	if a.tag ~= "table" then
		return types.newtable()
	else
		return a
	end
end

export type Widget<Events, SerdeType> = {
	serde: Serde<SerdeType>,
	emit: EmitFn<SerdeType, Events>,
	events_template: { [string]: events.EventShim<unknown> },

	construct: <Props, Out>(
		write: WriteFn<Props, Events, SerdeType, Out>,
		emit: EmitFn<SerdeType, Events>
	) -> <Scope>(scope: Scope, key: string, props: Props) -> setmetatable<Or<Out>, getmetatable<Scope>>,
}

local default_serde: Serde<any> = {
	read = function(diff: any, old: any)
		local type_new = typeof(diff)

		if type_new == "buffer" then
			return delta_compress.applyMutable(old, diff)
		else
			return diff
		end
	end,

	write = function(new: any, old: any)
		local type_new = typeof(new)

		if type_new ~= "table" and type_new ~= "buffer" and new == nil and old ~= nil then
			return if new == old then nil else new
		else
			return delta_compress.diffMutable(old, new)
		end
	end,
}

local widget_registrar = {
	registered = {} :: { [string]: Widget<{}, unknown> },
}

local scope_reusal: { [vdom.Node]: WriteScopeBase } = setmetatable({}, { __mode = "kv" }) :: any

local function get_scope(node: vdom.Node, diff: vdom.NodeDiff, outgoing: vdom.NodeDiff?)
	local old = scope_reusal[node]

	if old then
		old.idx = 0
		old.parent_diff = diff
		old.incoming_diff = outgoing
		return old
	else
		local scope = { parent = node, parent_diff = diff, incoming_diff = outgoing, idx = 0 }
		local function get_state<T>(value: T?)
			if node.state == false then
				node.state = {}
			end

			scope.idx += 1
			assert(node.state)

			return node.state[scope.idx] :: T,
				function(value: T)
					assert(node.state)
					node.state[scope.idx] = value
					return value
				end
		end
		scope.get_state = get_state

		scope_reusal[node] = scope :: any

		return scope :: any
	end
end

--[=[
Registers a new widget. Registering two widgets with the same key will throw an error.
A widget is represented by a node within the vdom. Users can optionally also specify
serde semantics for the widget

@param key A unique identifier for the widget
@param events A table of events which the widget has access to. Events allow for two-way communication.
@param serde Optionally defines a serialization type for properties. By default, this is delta compression.
]=]
function widget_registrar.register<Events, SerdeType>(
	identifier: string,
	events_template: Events,
	serde: Serde<SerdeType>?
): Widget<Events, SerdeType>
	serde = serde or default_serde

	local widget = { serde = serde, events_template = events_template, emit = nil :: any }

	function widget.construct<Props, Out>(write: WriteFn<Props, Events, SerdeType, Out>, emit: EmitFn<SerdeType, Events>)
		widget.emit = emit
		return function(scope: WriteScopeBase, key: string, props: Props)
			assert(serde)

			local node, diff = vdom.create_node(scope.parent, scope.parent_diff, identifier, key)
			local incoming_diff = scope.incoming_diff
				and scope.incoming_diff.children
				and scope.incoming_diff.children[key]
			local base_scope = setmetatable(get_scope(node, diff, incoming_diff), getmetatable(scope))
			local events = events.server(node, events_template, incoming_diff)

			local serde_out, out = write(props, base_scope, events :: any)

			local result = serde.write(serde_out, node.props)
			diff.props = result
			node.props = serde_out

			if out and typeof(out) == "table" then
				for key, value in out :: any do
					(base_scope :: any)[key] = value
				end
				return base_scope
			elseif typeof(out) == "nil" then
				return base_scope
			else
				error("output of base must be a table or nil")
			end
		end
	end

	widget_registrar.registered[identifier] = widget :: any

	return widget :: any
end

function widget_registrar.get(key: string)
	local widget = widget_registrar.registered[key]
	assert(widget, `missing widget {key}; has widget been registered?`)

	return widget
end

widget_registrar._ = scope_reusal

return widget_registrar
