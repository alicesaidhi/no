local parser = require("./parser")
local define_styles = {}

type Transition<Property> = {
	property: Property,
	style: Enum.EasingStyle?,
	direction: Enum.EasingDirection?,
	time: number?,
	delay_time: number?,
}

type Indexer<Property> = Transition<Property> | Rule

type Property<T> = T | nil

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

export type function GetInstanceProperties(t: type): type
	if t.tag == "union" then
		local components: { type } = {}

		for i, component in t:components() do
			table.insert(components, GetInstanceProperties(component))
		end

		local base = components[1]
		local properties = {}

		for key, value in base:properties() do
			local exists = true
			local write = value.write

			if not write then
				continue
			end

			for i = 2, #components do
				local other = components[i]
				local other_value = other:readproperty(key)
				if other_value == nil then
					exists = false
					break
				else
					write = types.unionof(write, other_value)
				end
			end

			if not exists then
				continue
			end
			table.insert(properties, key)
			base:setproperty(key, write)
		end

		base:setindexer(types.number, Indexer(types.unionof(unpack(properties))))

		return base
	elseif t.tag == "intersection" then
		-- combine both
		local components = t:components()
		local main = types.newtable({})
		local properties: { type } = {}

		for _, value in components do
			for key, value in GetInstanceProperties(value):properties() do
				table.insert(properties, key)
				if value.read then
					main:setreadproperty(key, Property(value.read))
				end
				if value.write then
					main:setwriteproperty(key, Property(value.write))
				end
			end
		end

		main:setindexer(types.number, Indexer(types.unionof(unpack(properties))))

		return main
	elseif t.tag == "extern" then
		local main = types.newtable({})
		local properties: { type } = {}
		local readonly = {
			"ClassName",
			"UniqueId",
			"RobloxLocked",
		}

		local processing = t

		while processing do
			for key, value in processing:properties() do
				if
					value.read
					and (value.read.tag == "function" or value.read.tag == "table" or is_signal(value.read))
				then
					continue
				end

				if table.find(readonly, key:value() :: string) then
					continue
				end

				table.insert(properties, key)
				if value.read then
					main:setreadproperty(key, Property(value.read))
				end
				if value.write then
					main:setwriteproperty(key, Property(value.write))
				end
			end

			processing = processing:readparent()
		end

		main:setindexer(types.number, Transition(types.unionof(unpack(properties))))

		return main
	elseif t.tag == "table" then
		return t
	else
		error("not valid")
	end
end

export type Rule = {
	type: "rule",

	selector: string,
	properties: { [string]: any },
	priority: number?,
}

export type Token = {
	type: "token",

	name: string,
	value: any,
}

export type StyleData = Rule | Token

function define_styles.rule<Selector>(selector: Selector | "", priority: number?)
	return function(properties: GetInstanceProperties<parser.get_instance_type<Selector>>): Rule
		return {
			type = "rule",

			selector = selector,
			properties = properties,
			priority = priority,
		}
	end
end

function define_styles.token(name: string, value: any): Token
	return {
		type = "token",
		name = name,
		value = value,
	}
end

function define_styles.sheet(style_data_array: { StyleData }): StyleSheet
	local sheet = Instance.new("StyleSheet")

	local function create_rule(style_data: Rule)
		local rule = Instance.new("StyleRule")
		rule.Name = style_data.selector
		local props = {}
		local transitions = {}

		for key, value in style_data.properties do
			if type(key) == "string" and type(value) ~= "table" then
				props[key] = value
			elseif type(key) == "number" and type(value) == "table" and value.type == "rule" then
				create_rule(value).Parent = rule
			elseif type(key) == "number" then
				local transition: Transition<any> = value
				transitions[transition.property] = TweenInfo.new(
					transition.time,
					transition.style,
					transition.direction,
					0,
					false,
					transition.delay_time
				)
			end
		end

		rule.Selector = style_data.selector
		rule:SetProperties(props)
		if next(transitions) then
			rule:SetPropertyTransitions(transitions)
		end
		if style_data.priority then
			rule.Priority = style_data.priority
		end

		return rule
	end

	for _, style_data in style_data_array do
		if style_data.type == "rule" then
			local rule = create_rule(style_data)

			rule.Parent = sheet
		elseif style_data.type == "token" then
			sheet:SetAttribute(style_data.name, style_data.value)
		end
	end

	return sheet
end

function define_styles.link(target: Instance, sheet: StyleSheet)
	local link = Instance.new("StyleLink")
	link.Name = sheet.Name
	link.StyleSheet = sheet

	link.Parent = target
	return link
end

return define_styles
