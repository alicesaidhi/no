local events = require("../events")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

type Props = {
	min: number,
	max: number,
	step: number,
	value: number,
}

local slider = widget_registrar.register("nx_slider", {
	changed = events.event(),
}, (nil :: any) :: widget_registrar.Serde<Props>)

return slider.construct(function(props: Props, scope, events)
	return props, {
		value = (events.changed:poll() or props.value) :: number?,
	}
end, function(scope, events)
	local base = create("Frame")({
		Name = scope.key,
		tags = { "nx_slider_base" },
	})

	local slider_holder: ImageButton
	local label: TextLabel
	local slider_bar: Frame
    local props: Props

	local function update_visuals(value: number, frac: number)
		label.Text = string.format("%.3g", value)
		slider_bar.Position = UDim2.fromScale(frac, 0)
	end

	slider_holder = create("ImageButton")({
		Parent = base,
		tags = { "nx_slider_holder", "border" },
		AutoButtonColor = false,

		MouseButton1Down = function(x)
			local frac = (x - slider_holder.AbsolutePosition.X) / slider_holder.AbsoluteSize.X
            local value = frac * props.max
            update_visuals(value, frac)
            events.changed:fire(value)
		end,
	})

	label = create("TextLabel")({
		Parent = slider_holder,
		ZIndex = 5,

		tags = { "nx_label", "nx_slider_holder" },
	})

	slider_bar = create("Frame")({
		Parent = slider_holder,
		tags = { "nx_slider_bar" },
	})

	-- Larger but invisible to make dragging easier
	local slider_bar_button = create("ImageButton")({
		Size = UDim2.new(1, 8, 1, 8),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = slider_bar,
	})

	local drag_detector = create("UIDragDetector")({
		Parent = slider_bar_button,

		BoundingUI = slider_holder,
		ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomScale,
		DragRelativity = Enum.UIDragDetectorDragRelativity.Relative,

		DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,
	})

	scope.on_updated_props(function(new_props)
        props = new_props
		assert(props.max >= props.min)

		local clamped = math.clamp(props.value, props.min, props.max)
		local frac = clamped / props.max

		drag_detector.DragUDim2 = UDim2.fromScale(frac, 0)
		update_visuals(props.value, frac)

		drag_detector:SetDragStyleFunction(function(position: Vector2)
			local diff = position.X - slider_holder.AbsolutePosition.X
			local frac = math.clamp(diff / slider_holder.AbsoluteSize.X, 0, 1)
			local clamped = math.clamp(frac * props.max, props.min, props.max)

			local rounded = math.round(clamped / props.step) * props.step
			local rounded_frac = rounded / props.max

			slider_bar.Position = UDim2.fromScale(rounded_frac, 0)
			update_visuals(rounded, rounded_frac)
			events.changed:fire(rounded)

			return UDim2.fromScale(rounded_frac, 0), 0
		end)
	end)

	scope.cleanup(base)

	return base, nil
end)
