local vdom = require("./vdom")

export type SerdeNoDiff<T> = {
	read: (diff: any) -> T,
	write: (new: T) -> any,
}

export type EventShim<T> = {
	serde: SerdeNoDiff<T>?,
	_: T,
}

export type EventServer<T> = {
	poll: (EventServer<T>) -> (T) -> (),
}

export type EventClient<T> = {
	fire: (EventClient<T>, T) -> (),
}

export type function ShimToEventClient(type: type)
	if type.tag ~= "table" then
		return types.never
	end

	local new = types.newtable({})

	for key, value in type:properties() do
		local read = value.read
		assert(read)
		local serde = read:readproperty(types.singleton("_"))
		new:setproperty(key, EventClient(serde))
	end

	return new
end

export type function ShimToEventServer(type: type)
	if type.tag ~= "table" then
		return types.never
	end

	local new = types.newtable({})

	for key, value in type:properties() do
		local read = value.read
		assert(read)
		local serde = read:readproperty(types.singleton("_"))
		new:setproperty(key, EventServer(serde))
	end

	return new
end

local events = {}

local client_events_reusal: { [vdom.Node]: { [string]: EventClient<unknown> } } = setmetatable({}, { __mode = "kv" }) :: any

function events.client(node: vdom.Node, events_shims: { [string]: EventShim<unknown> })
	local old = client_events_reusal[node]

	if old then
		return old
	else
		local events = {}

		local idx = 0
		for key, value in events_shims do
			idx += 1
			local event = {}

			function event:fire(value: unknown)
				node.state = node.state or {}
				assert(node.state)
				node.state[idx] = value
			end

			events[key] = event :: any
		end

		client_events_reusal[node] = events
		return events
	end
end

local server_events_reusal: { [vdom.Node]: { [string]: EventClient<unknown> } } = setmetatable({}, { __mode = "kv" }) :: any
local server_events_diff: { [vdom.Node]: vdom.NodeDiff } = setmetatable({}, { __mode = "kv" }) :: any

function events.server(node: vdom.Node, events_shims: { [string]: EventShim<unknown> }, incoming_diff: vdom.NodeDiff?)
	local old = server_events_reusal[node]
	server_events_diff[node] = incoming_diff :: any

	if old then
		return old
	else
		local events = {}

		local idx = 0
		for key, value in events_shims do
			idx += 1
			local event = {}

			function event:poll(value: unknown)
				local incoming_diff = server_events_diff[node]
				return incoming_diff and incoming_diff.events and incoming_diff.events[idx] :: any
			end

			events[key] = event :: any
		end

		server_events_reusal[node] = events
		return events
	end
end

--[=[
Defines a shim for an event
]=]
function events.event<T>(serde: SerdeNoDiff<T>?): EventShim<T>
	return {
		serde = serde,
		_ = nil :: any,
	}
end

return events
