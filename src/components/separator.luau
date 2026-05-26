local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local separator = widget_registrar.register("nx_separator", {}, (nil :: any) :: widget_registrar.Serde<string>)

return separator.construct(function(props: string, scope, events)
	return props, nil
end, function(scope, events, parent)
	local label = create("TextLabel")({
		tags = { "nx_label", "background" },
	})

	local separator = create("Frame")({
		Name = scope.key,
		tags = { "separator" },

		create("Frame")({
			Name = "decoration",
		}),

		label,
	})

	scope.cleanup(separator)
	scope.on_updated_props(function(value)
		label.Text = value
	end)

	return separator, nil
end)
