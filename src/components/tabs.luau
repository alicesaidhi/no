local events = require("../events")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

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
		tags = { "container", "border", "background" },
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
		instances,
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
