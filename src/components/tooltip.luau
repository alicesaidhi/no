local events = require("../events")
local stylesheets = require("../stylesheets")
local define_styles = require("../stylesheets/define_styles")
local theme = require("../stylesheets/sheets/theme")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local rule = define_styles.rule

local MAX_SIZE = 450

stylesheets.append_sheet({
	rule(".nx_tooltip GuiObject")({
		AutomaticSize = Enum.AutomaticSize.XY,

		BackgroundColor3 = theme.background(1),
		BackgroundTransparency = 0,

		rule("::UISizeConstraint")({
			MaxSize = Vector2.new(MAX_SIZE, math.huge),
		}),

		rule("::UIShadow")({
			Spread = UDim2.new(0, 1, 0, 1),
			BlurRadius = UDim.new(0, 16),
			Transparency = 0.7,
		}),

		rule("::UIPadding")({
			PaddingTop = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
		}),
	}),
})

local tooltip = widget_registrar.register("nx_tooltip", {
	turns_visible = events.event(),
}, (nil :: any) :: widget_registrar.Serde<string?>)

return tooltip.construct(function(props: string?, scope, events)
	local visible, set_visible = scope.get_state()

	if visible == nil then
		set_visible(false)
		visible = false
	end

	if events.turns_visible:poll() ~= nil then
		set_visible(events.turns_visible:poll())
		visible = events.turns_visible:poll()
	end

	return props, { visible = visible }
end, function(scope, events, parent)
	local label = create("TextLabel")({
		tags = { "nx_label" },
	})

	local tooltip = create("Frame")({
		Name = scope.key,
		tags = { "nx_tooltip", "container", "tooltip" },

		label,
	})
	local folder = create("ScreenGui")({
		Name = scope.key,
		Enabled = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

		tooltip,
	})

	local nearest_gui_object = if parent:IsA("GuiObject") then parent else parent:FindFirstAncestorWhichIsA("GuiObject")

	if nearest_gui_object then
		local display_thread: thread?
		local function update_position(x: number, y: number)
			local swap_x = false

			if x + 16 > workspace.CurrentCamera.ViewportSize.X - MAX_SIZE then
				swap_x = true
			end

			tooltip.Position = UDim2.fromOffset(if swap_x then x - 16 else x + 16, y + 16)
			tooltip.AnchorPoint = if swap_x then Vector2.new(1, 0) else Vector2.zero
		end

		scope.cleanup(nearest_gui_object.MouseEnter:Connect(function(x, y)
			update_position(x, y)
			display_thread = task.delay(0.5, function()
				folder.Enabled = true
				events.turns_visible:fire(true)
			end)
		end))
		scope.cleanup(nearest_gui_object.MouseLeave:Connect(function(x, y)
			folder.Enabled = false
			update_position(x, y)

			if display_thread then
				task.cancel(display_thread)
				display_thread = nil
				events.turns_visible:fire(false)
			end
		end))
		scope.cleanup(nearest_gui_object.MouseMoved:Connect(update_position))
	end

	scope.cleanup(folder)
	scope.on_updated_props(function(value)
		if value then
			label.Text = value
			label.Visible = true
		else
			label.Visible = false
		end
	end)

	return folder, tooltip
end)
