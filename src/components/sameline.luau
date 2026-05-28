local stylesheets = require("../stylesheets")
local define_styles = require("../stylesheets/define_styles")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local rule = define_styles.rule

stylesheets.append_sheet({
	rule(".sameline GuiObject")({
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),

		rule("::UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),

			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		}),
	}),
})

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
