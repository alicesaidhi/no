local events = require("../events")
local stylesheets = require("../stylesheets")
local define_styles = require("../stylesheets/define_styles")
local theme = require("../stylesheets/sheets/theme")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local rule = define_styles.rule

stylesheets.append_sheet({
	rule(".nx_checkbox ImageButton")({
		AutomaticSize = Enum.AutomaticSize.XY,

		Size = UDim2.fromOffset(16, 16),

		rule("::UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 4),
		}),

		rule("> #icon ImageLabel")({
			Size = UDim2.fromOffset(12, 12),
			ScaleType = Enum.ScaleType.Fit,
			Image = "rbxassetid://100188624502987",
			ImageTransparency = 1,
			BackgroundTransparency = 0,
			BackgroundColor3 = theme.background(-2),

			rule("::UICorner")({
				CornerRadius = UDim.new(0, 2),
			}),
			rule("::UIStroke")({
				Color = theme.background(-6),
			}),
		}),

		rule(":hover > #icon ::UIStroke")({
			Color = theme.accent(3),
		}),

		rule(".checked > #icon ImageLabel")({
			ImageTransparency = 0,
			BackgroundColor3 = theme.accent(2),

			rule("::UIStroke")({
				Color = theme.accent(-3),
			}),
		}),
	}),
})

type Props = {
	text: string,
	checked: boolean,
}

local checkbox = widget_registrar.register("nx_checkbox", {
	toggled = events.event(),
}, (nil :: any) :: widget_registrar.Serde<Props>)

return checkbox.construct(function(props: { text: string, checked: boolean }, scope, events)
	return props, {
		fired = (events.toggled:poll() or false) :: boolean,
	}
end, function(scope, events)
	local checkbox_icon = create("ImageLabel")({
		Name = "icon",
	})

	local text = create("TextLabel")({
		Name = "text",
		tags = { "nx_label" },
	})

	local checkbox = create("ImageButton")({
		Name = scope.key,
		tags = { "nx_checkbox" },

		Activated = function()
			events.toggled:fire(true)
		end,

		text,
		checkbox_icon,
	})

	scope.cleanup(checkbox)

	scope.on_updated_props(function(props)
		if props.checked then
			checkbox:AddTag("checked")
		elseif not props.checked then
			checkbox:RemoveTag("checked")
		end

		text.Text = props.text
	end)

	return checkbox, nil
end)
