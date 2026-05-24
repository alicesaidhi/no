local widget_registrar = require("../widget_registrar")

local label = widget_registrar.register("nx_label", {
	test = true,
}, (nil :: any) :: widget_registrar.Serde<string>)

local label_fn = label.construct(function(props: string, scope, events)
	return props, nil
end, function(scope, events, parent)
	local label = Instance.new("TextLabel")
	label.Name = scope.key
	label:AddTag("nx_label")

	label.Parent = parent

	scope.cleanup(label)
	scope.on_updated_props(function(value)
		label.Text = value
	end)

	return label, nil
end)

local a, b = label_fn({}, "test", "thing")
