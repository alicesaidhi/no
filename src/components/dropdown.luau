local events = require("../events")
local stylesheets = require("../stylesheets")
local define_styles = require("../stylesheets/define_styles")
local theme = require("../stylesheets/sheets/theme")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local rule = define_styles.rule

stylesheets.append_sheet({
	rule(".nx_dropdown GuiObject")({
		Size = UDim2.new(0, 100, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		rule("::UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
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

		rule("> #children > #children GuiObject")({
			AutomaticSize = Enum.AutomaticSize.Y,

			rule("::UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			}),

			rule(">> .nx_button TextButton")({
				TextXAlignment = Enum.TextXAlignment.Left,

				rule("::UICorner")({
					CornerRadius = UDim.new(),
				}),
			}),
		}),
	}),
})

type Props = {
	set_to: string,
	options: { string },
}

local dropdown = widget_registrar.register("nx_dropdown", {
	set_value = events.event(),
}, (nil :: any) :: widget_registrar.Serde<Props>)

return dropdown.construct(function(
	p: {
		set_to: string,
		options: { string },
	},
	scope,
	events
)
	return { set_to = p.set_to, options = p.options }, {
		set_to = function(): string?
			return events.set_value:poll()
		end,
	}
end, function(scope, events)
	local expand
	local collapse
	local expanded = false
	local options: { [string]: TextButton } = {}

	local children = create("Frame")({
		Name = "children",
		tags = { "container" },
	})

	local screengui = create("ScreenGui")({
		Name = "children",

		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = false,

		children,
	})

	local name = create("TextLabel")({
		Name = "text",
		tags = { "nx_label" },
	})

	local arrow = create("ImageLabel")({
		Name = "arrow",
		tags = { "arrow_right" },
	})

	local button = create("ImageButton")({
		Name = "button",
		tags = { "accent", "border" },

		arrow,
		name,

		Activated = function()
			if expanded then
				collapse()
			else
				expand()
			end
		end,
	})

	local collapsible = create("Frame")({
		Name = scope.key,
		tags = { "nx_dropdown" },

		button,
		screengui,

		create("Frame")({
			Name = "border",
		}),
	})

	local function update()
		children.Position = UDim2.fromOffset(
			collapsible.AbsolutePosition.X,
			collapsible.AbsolutePosition.Y + collapsible.AbsoluteSize.Y
		)
		children.Size = UDim2.fromOffset(collapsible.AbsoluteSize.X, collapsible.AbsoluteSize.Y)
	end

	update()

	collapsible:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
	collapsible:GetPropertyChangedSignal("AbsolutePosition"):Connect(update)

	function expand()
		expanded = true
		screengui.Enabled = true
		collapsible:AddTag("expanded")
		arrow:AddTag("arrow_down")
		arrow:RemoveTag("arrow_right")
	end

	function collapse()
		expanded = false
		screengui.Enabled = false
		collapsible:RemoveTag("expanded")
		arrow:AddTag("arrow_right")
		arrow:RemoveTag("arrow_down")
	end

	local function create_option(option: string)
		return create("TextButton")({
			Name = option,
			Parent = children,
			tags = { "nx_label", "nx_button", "border", "accent" },

			Text = option,

			Activated = function()
				collapse()
				events.set_value:fire(option)
			end,
		})
	end

	scope.cleanup(collapsible)

	scope.on_updated_props(function(p)
		name.Text = p.set_to

		local set = {}
		for _, option in p.options do
			if options[option] then
				continue
			end
			set[option] = true
			options[option] = create_option(option)
		end

		for option, instance in options do
			if set[option] == nil then
				instance:Destroy()
				options[option] = nil
			end
		end
	end)

	return collapsible, children
end)
