local events = require("../events")
local stylesheets = require("../stylesheets")
local define_styles = require("../stylesheets/define_styles")
local theme = require("../stylesheets/sheets/theme")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local rule = define_styles.rule

stylesheets.append_sheet({
	rule(".nx_button GuiObject")({
		Size = UDim2.fromOffset(40, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = theme.background(5),
		BackgroundTransparency = 0,

		rule("TextButton")({
			AutoButtonColor = false,
			TextXAlignment = Enum.TextXAlignment.Center,
		}),

		rule("::UIPadding")({
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
		}),

		rule("::UICorner")({
			CornerRadius = UDim.new(0, 2),
		}),

		rule("GuiObject :hover")({
			BackgroundColor3 = theme.background(6),
		}),
		rule("GuiObject :press")({
			BackgroundColor3 = theme.background(3),
		}),

		rule("GuiObject .accent")({
			BackgroundColor3 = theme.accent(0),

			rule("GuiObject :hover")({
				BackgroundColor3 = theme.accent(1),
			}),
			rule("GuiObject :press")({
				BackgroundColor3 = theme.accent(-2),
			}),
		}),
	}),
})

local button =
	widget_registrar.register("nx_button", { click = events.event() }, (nil :: any) :: widget_registrar.Serde<string>)

return button.construct(function(props: string, scope, events)
	return props, { clicked = events.click:poll() or false }
end, function(scope, events, parent)
	local button = create("TextButton")({
		Name = scope.key,
		tags = { "nx_label", "nx_button", "border", "accent" },

		Activated = function()
			events.click:fire(true)
		end,
	})

	scope.on_updated_props(function(text)
		button.Text = text
	end)

	scope.cleanup(button)

	return button, nil
end)
