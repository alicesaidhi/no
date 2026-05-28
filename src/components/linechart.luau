local stylesheets = require("../stylesheets")
local define_styles = require("../stylesheets/define_styles")
local theme = require("../stylesheets/sheets/theme")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local rule = define_styles.rule

stylesheets.append_sheet({
	rule(".nx_graph GuiObject")({
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 200),

		BackgroundColor3 = theme.background(-1),
		BackgroundTransparency = 0,
		ClipsDescendants = true,

		rule("> GuiObject #labels")({
			LayoutOrder = 0,
			Visible = false,
		}),

		rule(".labels > GuiObject #labels")({
			Size = UDim2.new(0, 40, 1, 0),
			ZIndex = 100,
			Visible = true,
		}),

		rule("> GuiObject #graph")({
			LayoutOrder = 10,
			Size = UDim2.new(0, 400, 1, 0),

			rule(">> #path Path2D")({
				Color3 = theme.text,
				Closed = false,
				Thickness = 1,
				ZIndex = 100,
			}),
			rule(">> #lines Path2D")({
				Color3 = theme.background(8),
				Closed = false,
				Thickness = 0.5,
			}),
		}),

		rule("::UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
		}),

		rule("::UIStroke")({
			Color = theme.background(-3),
		}),
	}),
})

type Props = {
	metric_unit: string?,

	min: number?,
	max: number?,
	x_steps: number?,
	y_steps: number?,
	values: { number },
}

local REPLACE_GRAPH = 0
local INSERT_VALUE_AT_END = 1
local INSERT_VALUE_AT_END_REMOVE_VALUE_AT_START = 2
local DO_NOTHING = 5

local serde: widget_registrar.Serde<Props> = {
	write = function(new, old)
		if old == nil then
			local flags = 0b0000
			local flags_changed = 0b0000

			flags += if new.min then 0b10000 else 0
			flags += if new.max then 0b01000 else 0
			flags += if new.x_steps then 0b00100 else 0
			flags += if new.y_steps then 0b00010 else 0
			flags += if new.metric_unit then 0b00001 else 0

			flags_changed = flags

			local size = (if new.min then 8 else 0)
				+ (if new.max then 8 else 0)
				+ (if new.x_steps then 8 else 0)
				+ (if new.y_steps then 8 else 0)
				+ (if new.metric_unit then 1 + #new.metric_unit else 0)
				+ #new.values * 8
				+ 3
			local offset = 0
			local b = buffer.create(size)

			buffer.writeu8(b, offset, flags)
			buffer.writeu8(b, offset + 1, flags_changed)
			offset += 2

			if new.min then
				buffer.writef64(b, offset, new.min)
				offset += 8
			end

			if new.max then
				buffer.writef64(b, offset, new.max)
				offset += 8
			end

			if new.x_steps then
				buffer.writef64(b, offset, new.x_steps)
				offset += 8
			end

			if new.y_steps then
				buffer.writef64(b, offset, new.y_steps)
				offset += 8
			end

			if new.metric_unit then
				buffer.writeu8(b, offset, #new.metric_unit)
				buffer.writestring(b, offset + 1, new.metric_unit)
				offset += 1 + #new.metric_unit
			end

			buffer.writeu8(b, offset, REPLACE_GRAPH)
			offset += 1

			for i, value in new.values do
				buffer.writef64(b, offset + (i - 1) * 8, value)
			end

			return b
		else
			local flags = 0b00000
			local flags_changed = 0b00000

			local function analyze(new: { number }, old: { number }): (number, number)
				if new == old then
					return DO_NOTHING, 0
				end

				-- first analyze if the contents are the same except for end
				if #new > #old then
					local can_optimize = true

					for i = 1, #old do
						if old[i] ~= new[i] then
							can_optimize = false
						end
					end

					if can_optimize then
						return INSERT_VALUE_AT_END, 0
					else
						return REPLACE_GRAPH, 0
					end
				elseif #new == #old then
					-- check how long it takes before we are in familiar territory

					-- case 0: is length of new long enough for it to be worth inserting / popping
					if #new < 8 then
						return REPLACE_GRAPH, 0
					end

					-- case 1: check if the value is pushed at the end, some values at the start might be discarded. from there, assume all values are the same.
					-- the value returned alongside says the position where numbers are inserted from
					local len = #old
					for i = len, len // 2, -1 do
						if new[i] == old[len] then
							local matching = true
							for j = 1, i - 1 do
								if new[i - j] ~= old[len - j] then
									matching = false
									break
								end
							end

							if matching and i == len then
								return INSERT_VALUE_AT_END, 0
							elseif matching then
								return INSERT_VALUE_AT_END_REMOVE_VALUE_AT_START, i + 1
							end
						end
					end

					return REPLACE_GRAPH, 0
				else
					return REPLACE_GRAPH, 0
				end
			end

			flags += if new.min then 0b10000 else 0
			flags += if new.max then 0b01000 else 0
			flags += if new.x_steps then 0b00100 else 0
			flags += if new.y_steps then 0b00010 else 0
			flags += if new.metric_unit then 0b00001 else 0

			flags_changed += if new.min ~= old.min then 0b10000 else 0
			flags_changed += if new.max ~= old.max then 0b01000 else 0
			flags_changed += if new.x_steps ~= old.x_steps then 0b00100 else 0
			flags_changed += if new.y_steps ~= old.y_steps then 0b00010 else 0
			flags_changed += if new.metric_unit ~= old.metric_unit then 0b00001 else 0
			local type, insert_from = analyze(new.values, old.values)

			if type == DO_NOTHING and flags == 0 then
				return nil -- no change!
			end

			local size_values = if type == REPLACE_GRAPH
				then #new.values
				elseif type == INSERT_VALUE_AT_END then #new.values - #old.values
				elseif type == INSERT_VALUE_AT_END_REMOVE_VALUE_AT_START then #new.values - insert_from + 1
				elseif type == DO_NOTHING then 0
				else 0

			local size = (if new.min ~= old.min then 8 else 0)
				+ (if new.max ~= old.max then 8 else 0)
				+ (if new.x_steps ~= new.x_steps then 8 else 0)
				+ (if new.y_steps ~= old.y_steps then 8 else 0)
				+ (if new.metric_unit ~= old.metric_unit and new.metric_unit then 1 + #new.metric_unit else 0)
				+ size_values * 8
				+ 3
			local offset = 0
			local b = buffer.create(size)

			buffer.writeu8(b, offset, flags)
			buffer.writeu8(b, offset + 1, flags_changed)
			offset += 2

			if new.min and new.min ~= old.min then
				buffer.writef64(b, offset, new.min)
				offset += 8
			end

			if new.max and new.max ~= old.max then
				buffer.writef64(b, offset, new.max)
				offset += 8
			end

			if new.x_steps and new.x_steps ~= old.x_steps then
				buffer.writef64(b, offset, new.x_steps)
				offset += 8
			end

			if new.y_steps and new.y_steps ~= old.y_steps then
				buffer.writef64(b, offset, new.y_steps)
				offset += 8
			end

			if new.metric_unit and new.metric_unit ~= old.metric_unit then
				buffer.writeu8(b, offset, #new.metric_unit)
				buffer.writestring(b, offset + 1, new.metric_unit)
				offset += 1 + #new.metric_unit
			end

			if type == REPLACE_GRAPH then
				buffer.writeu8(b, offset, REPLACE_GRAPH)
				offset += 1

				for i, value in new.values do
					buffer.writef64(b, offset + (i - 1) * 8, value)
				end
			elseif type == INSERT_VALUE_AT_END then
				buffer.writeu8(b, offset, INSERT_VALUE_AT_END)
				offset += 1

				local idx = 0
				for i = #old.values + 1, #new.values do
					buffer.writef64(b, offset + idx * 8, new.values[i])
					idx += 1
				end
			elseif type == INSERT_VALUE_AT_END_REMOVE_VALUE_AT_START then
				buffer.writeu8(b, offset, INSERT_VALUE_AT_END_REMOVE_VALUE_AT_START)
				offset += 1

				local idx = 0
				for i = insert_from, #new.values do
					buffer.writef64(b, offset + idx * 8, new.values[i])
					idx += 1
				end
			elseif type == DO_NOTHING then
				buffer.writeu8(b, offset, DO_NOTHING)
			end

			return b
		end
	end,

	read = function(diff: buffer, old)
		old = old or { values = {} } :: never

		local len = buffer.len(diff)
		local offset = 0
		local flags = buffer.readu8(diff, offset)
		local delta_flags = buffer.readu8(diff, offset + 1)

		offset += 2

		local has_min = bit32.btest(flags, 0b10000)
		local has_max = bit32.btest(flags, 0b01000)
		local has_x_steps = bit32.btest(flags, 0b00100)
		local has_y_steps = bit32.btest(flags, 0b00010)
		local has_metric = bit32.btest(flags, 0b00001)

		local min_changed = bit32.btest(delta_flags, 0b10000)
		local max_changed = bit32.btest(delta_flags, 0b01000)
		local x_steps_changed = bit32.btest(delta_flags, 0b00100)
		local y_steps_changed = bit32.btest(delta_flags, 0b00010)
		local metric_changed = bit32.btest(delta_flags, 0b00001)

		if min_changed then
			old.min = buffer.readf64(diff, offset)
			offset += 8
		elseif not has_min then
			old.min = nil
		end
		if max_changed then
			old.max = buffer.readf64(diff, offset)
			offset += 8
		elseif not has_max then
			old.max = nil
		end
		if x_steps_changed then
			old.x_steps = buffer.readf64(diff, offset)
			offset += 8
		elseif not has_x_steps then
			old.x_steps = nil
		end
		if y_steps_changed then
			old.y_steps = buffer.readf64(diff, offset)
			offset += 8
		elseif not has_y_steps then
			old.y_steps = nil
		end
		if metric_changed then
			local s = buffer.readu8(diff, offset)
			old.metric_unit = buffer.readstring(diff, offset + 1, s)
			offset += 1 + s
		elseif not has_metric then
			old.metric_unit = nil
		end

		local type = buffer.readu8(diff, offset)
		offset += 1

		if type == DO_NOTHING then
			return old
		elseif type == REPLACE_GRAPH then
			local idx = 0
			table.clear(old.values)
			for i = offset, len - 1, 8 do
				idx += 1
				old.values[idx] = buffer.readf64(diff, i)
			end
		elseif type == INSERT_VALUE_AT_END then
			for i = offset, len - 1, 8 do
				table.insert(old.values, buffer.readf64(diff, i))
			end
		elseif type == INSERT_VALUE_AT_END_REMOVE_VALUE_AT_START then
			local idx = 1
			local total = (len - offset) // 8
			table.move(old.values, 1 + total, #old.values, 1)
			for i = offset, len - 1, 8 do
				old.values[#old.values - total + idx] = buffer.readf64(diff, i)
				idx += 1
			end
		end

		return old
	end,
}

local linechart = widget_registrar.register("nx_linechart", {}, serde)

local MAX_EXPONENT = 5
local MIN_EXPONENT = -5
local map_units = {
	[5] = "P",
	[4] = "T",
	[3] = "G",
	[2] = "M",
	[1] = "k",
	[0] = "",
	[-1] = "m",
	[-2] = "μ",
	[-3] = "n",
	[-4] = "p",
	[-5] = "a",
}

return linechart.construct(function(props: Props, scope, events)
	local copy = table.clone(props.values)
	props.values = copy

	return props, nil
end, function(scope, events)
	local values = create("Path2D")({
		Name = "path",
	})
	local lines_x = create("Path2D")({
		Name = "lines",
	})
	local lines_y = create("Path2D")({
		Name = "lines",
	})

	local labels = {}

	local lines_y = create("Path2D")({
		Name = "lines",
	})

	local graph = create("CanvasGroup")({
		Name = "graph",

		values,
		lines_x,
		lines_y,
	})

	local labels = create("Frame")({
		Name = "labels",
	})

	local container = create("Frame")({
		Name = scope.key,
		tags = { "nx_graph" },

		labels,
		graph,
	})

	local labels_storage: { TextLabel } = {}

	local function create_textlabel()
		local label = create("TextLabel")({
			Name = "label",
			tags = { "nx_subtext", "nx_mono" },
		})

		label.Parent = labels

		table.insert(labels_storage, label)

		return label
	end

	scope.cleanup(container)

	scope.on_updated_props(function(props)
		local min = props.min or 10 ^ math.floor(math.log10(math.min(unpack(props.values))))
		local max = props.max or 10 ^ math.ceil(math.log10(math.max(unpack(props.values))))

		local function to_udim2(x: number, y: number)
			return UDim2.fromScale(x / (#props.values - 1), math.map(y, min, max, 1, 0))
		end

		local points = {}
		for i, value in props.values do
			points[i] = Path2DControlPoint.new(to_udim2(i - 1, value))
		end

		if props.x_steps then
			local line_points = {}
			local swap = 0
			for i = 1, #props.values, props.x_steps do
				table.insert(
					line_points,
					Path2DControlPoint.new(UDim2.fromScale(math.map(i, 1, #props.values, 0, 1), swap - (0.5 - swap)))
				)
				table.insert(
					line_points,
					Path2DControlPoint.new(UDim2.fromScale(math.map(i, 1, #props.values, 0, 1), (swap + 1) % 2))
				)

				swap = (swap + 1) % 2
			end
			lines_x:SetControlPoints(line_points)
		end

		if props.y_steps then
			container:AddTag("labels")
			local line_points = {}
			local swap = 0
			local idx = 0

			for i = min, max, props.y_steps do
				table.insert(line_points, Path2DControlPoint.new(UDim2.fromScale(swap, math.map(i, min, max, 1, 0))))
				table.insert(
					line_points,
					Path2DControlPoint.new(UDim2.fromScale((swap + 1) % 2, math.map(i, min, max, 1, 0)))
				)

				swap = (swap + 1) % 2

				idx += 1

				local exponent_div_3 = if i == 0 then 0 else math.clamp(math.log10(i) // 3, MIN_EXPONENT, MAX_EXPONENT)
				local prefix = map_units[exponent_div_3]

				local label = labels_storage[idx] or create_textlabel()
				label.Text = if props.metric_unit
					then string.format("%.3g %s%s", i / 10 ^ (exponent_div_3 * 3), prefix, props.metric_unit)
					else string.format("%.4g", i)
				label.Position = UDim2.fromScale(0, math.map(i, min, max, 1, 0))
				label.AnchorPoint = Vector2.new(0, math.map(i, min, max, 1, 0))
			end

			lines_y:SetControlPoints(line_points)
		else
			container:RemoveTag("labels")

			for _, label in labels_storage do
				label:Destroy()
			end
			table.clear(labels_storage)
		end

		values:SetControlPoints(points)
	end)

	return container, nil
end)
