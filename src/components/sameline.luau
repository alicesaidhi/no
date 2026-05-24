local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local sameline = widget_registrar.register("nx_sameline", {}, nil)

return sameline.construct(function(props, scope, events)
	return nil, nil
end, function(scope, events)
	local sameline = create("Frame")({
		Name = scope.key,
		tags = { "sameline" },
	})

	scope.cleanup(sameline)

	return sameline, nil
end)
