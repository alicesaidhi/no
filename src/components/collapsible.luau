local events = require("../events")
local stylesheets = require("../stylesheets")
local define_styles = require("../stylesheets/define_styles")
local theme = require("../stylesheets/sheets/theme")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local rule = define_styles.rule

stylesheets.append_sheet({
	rule(".nx_collapsible GuiObject")({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		rule("::UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),

		rule("::UIPadding")({
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
		}),

		rule("> #button ImageButton")({
			Size = UDim2.new(1, 0, 0, 16),

			BackgroundColor3 = theme.background(3),
			BackgroundTransparency = 0,
			AutoButtonColor = false,

			rule("::UICorner")({
				CornerRadius = UDim.new(0, 1),
			}),

			rule("GuiObject :hover")({
				BackgroundColor3 = theme.background(4),
			}),
			rule("GuiObject :press")({
				BackgroundColor3 = theme.background(-2),
			}),

			rule("GuiObject .accent")({
				BackgroundColor3 = theme.accent(0),

				rule("GuiObject :hover")({
					BackgroundColor3 = theme.accent(2),
				}),
				rule("GuiObject :press")({
					BackgroundColor3 = theme.accent(-2),
				}),
			}),

			rule("::UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
			}),
			rule("::UIPadding")({
				PaddingLeft = UDim.new(0, 0),
				PaddingRight = UDim.new(0, 0),
			}),
		}),

		rule("> #border GuiObject")({
			Visible = false,
		}),
		rule("> #children GuiObject")({
			Visible = false,
		}),

		rule(".expanded > #children GuiObject")({
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = true,
		}),

		rule(".expanded > #border GuiObject")({
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = theme.background(-2),
			BackgroundTransparency = 0,
			Visible = true,
		}),
	}),
})

type Props = {
	name: string,
	expanded: boolean,
}

local collapsible = widget_registrar.register("nx_collapsible", {
	click = events.event(),
}, (nil :: any) :: widget_registrar.Serde<Props>)

return collapsible.construct(function(
	p: {
		name: string,
		default: boolean?,
	},
	scope,
	events
)
	local expanded, set_expanded = scope.get_state(p.default or false)

	if p.default ~= nil and expanded == nil then
		expanded = p.default
		set_expanded(expanded)
	elseif expanded == nil then
		expanded = false
		set_expanded(false)
	end

	if events.click:poll() then
		set_expanded(not expanded)
	end

	return { name = p.name, expanded = expanded }, { expanded = expanded }
end, function(scope, events)
	local children = create("Frame")({
		Name = "children",
		tags = { "container" },
	})

	local name = create("TextLabel")({
		Name = "text",
		tags = { "nx_label" },
	})

	local arrow = create("ImageLabel")({
		Name = "arrow",
	})

	local button = create("ImageButton")({
		Name = "button",
		tags = { "accent", "border" },

		arrow,
		name,

		Activated = function()
			events.click:fire(true)
		end,
	})

	local collapsible = create("Frame")({
		Name = scope.key,
		tags = { "nx_collapsible" },

		button,
		children,

		create("Frame")({
			Name = "border",
		}),
	})

	scope.cleanup(collapsible)

	scope.on_updated_props(function(p)
		name.Text = p.name

		if p.expanded then
			collapsible:AddTag("expanded")
			arrow:AddTag("arrow_down")
			arrow:RemoveTag("arrow_right")
		else
			collapsible:RemoveTag("expanded")
			arrow:AddTag("arrow_right")
			arrow:RemoveTag("arrow_down")
		end
	end)

	return collapsible, children
end)
