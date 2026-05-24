local parser = require("./parser")
local define_styles = {}

type Transition<Property> = {
	property: Property,
	style: Enum.EasingStyle?,
	direction: Enum.EasingDirection?,
	time: number?,
	delay_time: number?,
}

type Property<T> = T | nil

export type function GetInstanceProperties(t: type): type
	if t.tag == "union" then
		local components = {}

		for _, component in t:components() do
			table.insert(components, GetInstanceProperties(component))
		end

		return types.unionof(unpack(components))
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

		main:setindexer(types.number, Transition(types.unionof(unpack(properties))))

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
					and (value.read.tag == "function" or value.read.tag == "table" or value.read.tag == "extern")
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

			processing = processing:readparent() or processing:writeparent()
		end

		main:setindexer(types.number, Transition(types.unionof(unpack(properties))))

		return main
	elseif t.tag == "table" then
		return t
	else
		error("not valid")
	end
end

type Rule = {
	type: "rule",

	selector: string,
	properties: { [string]: any },
	priority: number?,
}

type Token = {
	type: "token",

	name: string,
	value: any,
}

type StyleData = Rule | Token

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

	for _, style_data in style_data_array do
		if style_data.type == "rule" then
			local rule = Instance.new("StyleRule")
			local props = {}
			local transitions = {}

			for key, value in style_data.properties do
				if type(key) == "string" then
					props[key] = value
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
			rule:SetPropertyTransitions(transitions)

			if style_data.priority then
				rule.Priority = style_data.priority
			end

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
