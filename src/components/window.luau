local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local events = require("../events")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

type Properties = { title: string, w: number, h: number, closeable: boolean? }

local window = widget_registrar.register("nx_window", {
	close = events.event(),
}, (nil :: any) :: widget_registrar.Serde<Properties>)

return window.construct(function(props: Properties, scope, events)
	return props, { closed = events.close:poll() }
end, function(scope, events, parent)
	local w: number, h: number

	local title = create("TextLabel")({
		Name = "title",
		tags = { "nx_header" },

		LayoutOrder = 100,
		Text = "",
	})

	local close = create("TextButton")({
		Name = "close",

		LayoutOrder = 1000,
		Text = "x",
	})

	local container = create("ScrollingFrame")({
		Name = "container",
		tags = { "scrolling" },
	})

	local dragging = false
	-- local origin_x, origin_y = 0, 0

	-- local c = RunService.Heartbeat:Connect(function(dt)
	-- 	if not dragging then
	-- 		return
	-- 	end
	-- 	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) == false then
	-- 		dragging = false
	-- 		return
	-- 	end
	-- end)

	local window = create("Frame")({
		Parent = parent,
		tags = { "no_window", "background", "border" },

		Name = `window:{scope.key}`,
		Position = UDim2.fromOffset(16, 16),

		create("ImageButton")({
			Name = "header",
			tags = { "border" },

			-- MouseButton1Down = function(x, y)
			-- 	dragging = true
			-- end,

			title,
			close,
		}),

		container,
	})

	scope.cleanup(window)

	scope.on_updated_props(function(props)
		if w == nil and h == nil then
			w, h = props.w, props.h
			window.Size = UDim2.fromOffset(w, h + 20)
		end

		title.Text = props.title
		close.Interactable = if props.closeable ~= nil then props.closeable else true
	end)

	return window, container
end)
