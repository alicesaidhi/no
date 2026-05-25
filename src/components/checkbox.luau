local events = require("../events")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

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
