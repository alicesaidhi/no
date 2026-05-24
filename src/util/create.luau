local classes = require("../stylesheets/classes")

type Classes = classes.Classes

type UnknownConnectCallback = (...any) -> ()

type Signal = RBXScriptSignal

type function get_connect(v: type): type?
	local connect = v:readproperty(types.singleton("Connect"))

	if connect and connect:is("function") then
		local head = connect:parameters().head

		if not head then
			return nil
		end
		local callback = head[2]

		if callback and callback:is("function") then
			return callback
		end
	end

	return nil
end

type function is_signal(v: type): type?
	if v == Signal and v.tag == "class" then
		return UnknownConnectCallback
	-- luau lsp types RBXScriptSignals as tables
	elseif v.tag == "table" then
		local connect = get_connect(v)

		if connect then
			return connect
		end

		-- i cba to test if this is needed or not
		local metatable = v:metatable()

		if metatable then
			connect = get_connect(metatable)

			if connect then
				return connect
			end
		end
	end

	return nil
end

type Indexer = Instance
type Property<T> = T | nil

type Tags = { string }?

type function GetClassProps(t: type)
	if t.tag ~= "singleton" then
		return types.never
	end

	local name = t:value()
	local class: type = Classes:readproperty(t)

	if not class then
		error(`invalid class {name}`)
	end

	local properties = types.newtable({
		[types.singleton("tags")] = Tags,
	})

	local read_only_properties = table.freeze({
		types.singleton("RobloxLocked"),
		types.singleton("ClassName"),
		types.singleton("UniqueId"),
	})

	local current = class

	while current do
		for key, value in current:properties() do
			if value.read and value.read.tag == "function" then
				continue
			end
			if table.find(read_only_properties, key) then
				continue
			end

			local callback = is_signal(value.read)

			if callback then
				properties:setproperty(key :: any, types.optional(callback))
			else
				properties:setreadproperty(key, Property(value.read))
				properties:setwriteproperty(key, Property(value.write))
			end
		end

		current = current:readparent()
	end

	properties:setindexer(types.number, Indexer)

	return properties
end

local function create<T>(classname: T | "" | keyof<classes.Classes>)
	return function(p: GetClassProps<T>): index<classes.Classes, T>
		local instance = Instance.new(classname)

		for key, value in p :: any do
			if key == "tags" and typeof(value) == "table" then
				for key, value in value do
					instance:AddTag(value)
				end
			elseif type(value) == "function" then
				instance[key]:Connect(value)
			elseif type(key) == "number" and typeof(value) == "Instance" then
				value.Parent = instance
			else
				instance[key] = value
			end
		end

		return instance
	end
end

return create
