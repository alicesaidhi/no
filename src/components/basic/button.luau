local events = require("../../events")
local create = require("../../util/create")
local widget_registrar = require("../../widget_registrar")

local button =
	widget_registrar.register("nx_button", { click = events.event() }, (nil :: any) :: widget_registrar.Serde<string>)

return button.construct(function(props: string, scope, events)
	return props, { clicked = events.click:poll() }
end, function(scope, events, parent)
	local button = create("TextButton")({
		Name = scope.key,
		tags = { "nx_label", "nx_button", "border" },

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
