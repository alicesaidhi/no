local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local flexmode = widget_registrar.register(
	"flexmode",
	{},
	(nil :: any) :: widget_registrar.Serde<{
		grow: number,
		shrink: number,
	}>
)

return flexmode.construct(function(props: { grow: number, shrink: number }, scope, events)
	return props, nil
end, function(scope, events)
	local flex = create("UIFlexItem")({
		GrowRatio = 0,
		ShrinkRatio = 0,
		FlexMode = Enum.UIFlexMode.Custom,
	})

	scope.cleanup(flex)
	scope.on_updated_props(function(p)
		flex.GrowRatio = p.grow
		flex.ShrinkRatio = p.shrink
	end)

	return flex, nil
end)
