--!nolint
--!nocheck
local classes = require("./classes")

type ValidClasses = keyof<classes.Classes>

export type ClassSelector = {
	kind: "class_selector",
	class: ValidClasses,
}

export type TagSelector = {
	kind: "tag_selector",
	tag: string,
}

export type NameSelector = {
	kind: "name_selector",
	name: string,
}

export type MatchPropertySelector = {
	kind: "match_property",
	property: string,
	value: boolean | number | string,
}

export type MatchAttributeSelector = {
	kind: "match_attribute",
	attribute: string,
	value: boolean | number | string?, -- if nil, then matches any
}

export type MatchDirectChildrenCombinator = {
	kind: "direct_children",
}

export type MatchDescendantsCombinator = {
	kind: "match_descendants",
}

-- export type MatchOrCombinator = {
-- 	kind: "or",
-- }
export type StateSelector = {
	kind: "state",
	type: "hover" | "idle" | "press" | "noninteractable",
}

export type QuerySelector = {
	kind: "query",
	name: string,
}

export type PsuedoClassSelector = {
	kind: "psuedo_class",
	class: ValidClasses,
}

export type PsuedoClassNot = {
	kind: "not",
	target: SelectorList,
}

export type PsuedoClassHas = {
	kind: "has",
	target: SelectorList,
}

export type Selector =
	| ClassSelector
	| TagSelector
	| NameSelector
	| MatchPropertySelector
	| MatchAttributeSelector
	| MatchDirectChildrenCombinator
	| MatchDescendantsCombinator
	-- | MatchOrCombinator
	| StateSelector
	| QuerySelector
	| PsuedoClassSelector
	| PsuedoClassHas
	| PsuedoClassNot

export type SelectorList = { { Selector } }

export type Classes = classes.Classes

type function lex_selector(str: string)
	local function char(c: string)
		return string.byte(c)
	end

	local function is_whitespace(c: number)
		return c == char(" ") or c == char("\t") or c == char("\r") or c == char("\n")
	end

	local function is_digit(c: number)
		return char("0") <= c and c <= char("9")
	end

	local function is_alpha(c: number)
		return (char("a") <= c and c <= char("z"))
			or (char("A") <= c and c <= char("Z"))
			or c == char("_")
			or is_digit(c)
	end

	local function is_alphanumeric(c: number)
		return is_alpha(c) or is_digit(c)
	end

	local input = buffer.fromstring(str)
	local pos = 0
	local len = buffer.len(input)

	local function peek()
		if pos == len then
			return 0
		end
		return buffer.readu8(input, pos) :: any
	end

	local function bump()
		pos = math.min((pos + 1) :: any, len)
	end

	local function expect(char: number)
		if peek() ~= char then
			error(`expected {string.char(char)}, got {string.char(peek())}`)
		end
		bump()
	end

	local function skip_whitespace()
		while is_whitespace(peek()) do
			bump()
		end
	end

	local function parse_ident()
		local from = pos
		while is_alphanumeric(peek()) do
			bump()
		end

		assert(from ~= pos, `expected ident, got {string.char(peek())}`)

		return buffer.readstring(input, from, pos - from)
	end

	local function parse_number()
		local from = pos

		if peek() == char("-") then
			bump()
		end

		while is_digit(peek()) or peek() == char("e") or peek() == char("E") or peek() == char("_") do
			bump()
		end

		local b = buffer.readstring(input, from, pos - from)
		local n = tonumber(b:gsub("_", ""), 10)

		assert(n, `could not pass {b} into number`)

		return n
	end

	local function parse_class_name()
		local ident = parse_ident()

		assert(Classes:readproperty(types.singleton(ident)) ~= nil, `class {ident} is not a valid class`)

		return ident
	end

	local parse_selector_list: () -> SelectorList

	local function parse_class_selector(): ClassSelector
		local ident = parse_class_name()

		return {
			kind = "class_selector",
			class = ident :: any,
		}
	end

	local function parse_tag_selector(): TagSelector
		expect(char("."))

		local tag = parse_ident()

		return {
			kind = "tag_selector",
			tag = tag :: string,
		}
	end

	local function parse_name_selector(): NameSelector
		expect(char("#"))

		local name = parse_ident()

		return {
			kind = "name_selector",
			name = name :: string,
		}
	end

	local function parse_value(): string | boolean | number
		if is_digit(peek()) or peek() == char("-") then
			return parse_number()
		else
			local str = parse_ident()

			if str == "true" then
				return true
			elseif str == "false" then
				return false
			else
				return str
			end
		end
	end

	local function parse_match_selector(): MatchPropertySelector | MatchAttributeSelector
		expect(char("["))
		skip_whitespace()

		if peek() == char("$") then
			bump()
			local attribute = parse_ident()

			skip_whitespace()

			if peek() == char("=") then
				expect(char("="))
				skip_whitespace()

				local value = parse_value()

				expect(char("]"))
				return {
					kind = "match_attribute",
					attribute = attribute,
					value = value,
				}
			else
				expect(char("]"))
				return {
					kind = "match_attribute",
					attribute = attribute,
					value = nil,
				}
			end
		else
			local property = parse_ident()
			skip_whitespace()
			expect(char("="))
			skip_whitespace()
			local value = parse_value()
			expect(char("]"))

			return {
				kind = "match_property",
				property = property,
				value = value,
			}
		end
	end

	local function parse_match_children(): MatchDescendantsCombinator | MatchDirectChildrenCombinator
		expect(char(">"))

		if peek() == char(">") then
			expect(char(">"))

			return { kind = "match_descendants" }
		else
			return { kind = "direct_children" }
		end
	end

	local function parse_psuedo_selector(): StateSelector | PsuedoClassSelector | PsuedoClassHas | PsuedoClassNot
		expect(char(":"))

		if peek() == char(":") then
			bump()
			local ident = parse_class_name()

			return {
				kind = "psuedo_class",
				class = ident :: any,
			}
		else
			local ident = parse_ident()

			if ident == "not" then
				expect(char("("))
				local list = parse_selector_list()
				expect(char(")"))

				return {
					kind = "not",
					target = list,
				}
			elseif ident == "has" then
				expect(char("("))
				local list = parse_selector_list()
				expect(char(")"))

				return {
					kind = "has",
					target = list,
				}
			else
				return {
					kind = "state",
					type = ident :: any,
				}
			end
		end
	end

	local function parse_query(): QuerySelector
		expect(char("@"))

		local ident = parse_ident()

		return {
			kind = "query",
			name = ident,
		}
	end

	function parse_selector_list(): SelectorList
		local list: SelectorList = {}
		local active_selector: { Selector } = {}

		while true do
			skip_whitespace()
			if is_alpha(peek()) then
				table.insert(active_selector, parse_class_selector())
			elseif peek() == char("#") then
				table.insert(active_selector, parse_name_selector())
			elseif peek() == char(".") then
				table.insert(active_selector, parse_tag_selector())
			elseif peek() == char(":") then
				table.insert(active_selector, parse_psuedo_selector())
			elseif peek() == char(">") then
				table.insert(active_selector, parse_match_children())
			elseif peek() == char("[") then
				table.insert(active_selector, parse_match_selector())
			elseif peek() == char("@") then
				table.insert(active_selector, parse_query())
			elseif peek() == char(",") then
				bump()
				table.insert(list, active_selector)
				active_selector = {}
			elseif peek() == 0 then
				break
			elseif peek() == char(")") then
				break
			else
				error(`unable to parse {string.char(peek())} into selector`)
			end
		end

		table.insert(list, active_selector)

		return list
	end

	return parse_selector_list()
end

type instance = Instance

export type function get_instance_type(selector: type)
	assert(selector.tag == "singleton")
	local selectors = lex_selector(selector:value())

	local union: { type } = {}
	local Classes: type = Classes

	for _, value in selectors do
		local important_psuedoinstance_name: type? = nil
		local valid_instances: { type } = { instance }
		local required_properties: { [type]: type } = {}
		local valid_instances_idx = 1

		for _, selector in value do
			if selector.kind == "class_selector" then
				local class = Classes:readproperty(types.singleton(selector.class))
				valid_instances[valid_instances_idx] = class
				valid_instances_idx += 1
			elseif selector.kind == "match_property" then
				required_properties[types.singleton(selector.property)] = if typeof(selector.value) == "string"
					then types.string
					elseif typeof(selector.value) == "number" then types.number
					elseif typeof(selector.value) == "boolean" then types.boolean
					else nil
			elseif selector.kind == "direct_children" or selector.kind == "match_descendants" then
				table.clear(valid_instances)
				table.clear(required_properties)
				table.insert(valid_instances, instance)
				valid_instances_idx = 1
			elseif selector.kind == "psuedo_class" then
				if important_psuedoinstance_name then
					error("cannot have multiple psuedo class selectors")
				end

				local class = Classes:readproperty(types.singleton(selector.class))
				important_psuedoinstance_name = class
			end
		end

		if important_psuedoinstance_name then
			table.insert(union, important_psuedoinstance_name)
		else
			table.insert(
				union,
				types.intersectionof(types.unionof(unpack(valid_instances)), types.newtable(required_properties))
			)
		end
	end

	return types.unionof(unpack(union))
end

return {}
