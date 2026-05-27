local events = require("../events")
local stylesheets = require("../stylesheets")
local define_styles = require("../stylesheets/define_styles")
local theme = require("../stylesheets/sheets/theme")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local rule = define_styles.rule

stylesheets.append_sheet({
	rule(".nx_tabs GuiObject")({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		rule("::UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		rule("::UIPadding")({
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
		}),

		rule("> GuiObject #border")({
			Size = UDim2.new(1, 0, 0, 1),

			BackgroundColor3 = theme.background(-2),
			BackgroundTransparency = 0,
		}),

		rule("> GuiObject #tabs")({
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 0,
			ZIndex = 100,

			rule("::UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 1),
			}),
		}),

		rule("> GuiObject #container")({
			Size = UDim2.fromScale(1, 0),
			LayoutOrder = 10,
			AutomaticSize = Enum.AutomaticSize.Y,

			rule("::UIPadding")({
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 4),
			}),
		}),
	}),

	rule(".nx_tab GuiObject")({
		Size = UDim2.fromOffset(40, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = theme.background(2),
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
			TopLeftRadius = UDim.new(0, 2),
			TopRightRadius = UDim.new(0, 2),
			BottomLeftRadius = UDim.new(0, 0),
			BottomRightRadius = UDim.new(0, 0),
		}),

		rule("GuiObject :hover")({
			BackgroundColor3 = theme.background(3),
		}),
		rule("GuiObject :press")({
			BackgroundColor3 = theme.background(1),
		}),

		rule(".selected GuiObject")({
			BackgroundColor3 = theme.accent(0),

			rule("GuiObject :hover")({
				BackgroundColor3 = theme.accent(1),
			}),
			rule("GuiObject :press")({
				BackgroundColor3 = theme.accent(-1),
			}),
		}),
	}),
})

type Props = { visible: string?, options: { string } }

local tabs = widget_registrar.register("nx_tabs", {
	change_tab = events.event(),
}, (nil :: any) :: widget_registrar.Serde<Props>)

return tabs.construct(function(props: Props, scope, events)
	return props, { changed_tab = (events.change_tab:poll() or false) :: string | false }
end, function(scope, events)
	local map_tabs: { [string]: GuiObject } = {}

	local tabs = create("Frame")({
		Name = "tabs",
	})

	local instances = create("Frame")({
		Name = "container",
		tags = { "container", "background" },
	})

	local function create_tab(name: string)
		local button = create("TextButton")({
			Name = name,
			tags = { "nx_tab", "nx_label", "border" },

			Text = name,

			Activated = function()
				events.change_tab:fire(name)
			end,
		})

		button.Parent = tabs
		map_tabs[name] = button

		return button
	end

	local tabs = create("Frame")({
		Name = scope.key,
		tags = { "nx_tabs" },

		tabs,

		create("Frame")({
			Name = "border",
			LayoutOrder = 1,
		}),

		instances,

		create("Frame")({
			Name = "border",
			LayoutOrder = 20,
		}),
	})

	scope.cleanup(tabs)

	local previous_visible: string?
	scope.on_updated_props(function(props)
		for _, option in props.options do
			if map_tabs[option] ~= nil then
				continue
			end

			create_tab(option)
		end

		for name, tab in map_tabs do
			local idx = table.find(props.options, name)
			if idx == nil then
				tab:Destroy()
				map_tabs[name] = nil
			else
				map_tabs[name].LayoutOrder = idx
			end
		end

		local previous = map_tabs[previous_visible :: any]
		if previous then
			previous:RemoveTag("selected")
		end

		local current = map_tabs[props.visible :: any]
		if current then
			current:AddTag("selected")
		end

		previous_visible = props.visible
	end)

	return tabs, instances
end)
