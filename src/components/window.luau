local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local assets = require("../assets")
local events = require("../events")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

type Properties = { title: string, w: number, h: number, closeable: boolean? }

local window = widget_registrar.register("nx_window", {
	close = events.event(),
}, (nil :: any) :: widget_registrar.Serde<Properties>)

return window.construct(function(props: Properties, scope, events)
	local closed = events.close:poll()
	return props, { closed = closed }
end, function(scope, events, parent)
	local w: number, h: number

	local title = create("TextLabel")({
		Name = "title",
		tags = { "nx_header" },

		LayoutOrder = 100,
		Text = "",
	})

	local close = create("ImageButton")({
		Name = "close",

		LayoutOrder = 1000,

		Activated = function()
			events.close:fire(true)
		end,

		create("ImageLabel")({
			Name = "label",
		}),
	})

	local container = create("ScrollingFrame")({
		Name = "children",
		tags = { "scrolling", "container" },
	})

	local previous = Vector2.zero

	-- local c = RunService.Heartbeat:Connect(function(dt)
	-- 	if not dragging then
	-- 		return
	-- 	end
	-- 	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) == false then
	-- 		dragging = false
	-- 		return
	-- 	end
	-- end)

	local window: Frame
	window = create("Frame")({
		tags = { "no_window", "background", "border" },

		Name = `window:{scope.key}`,
		Position = UDim2.fromOffset(32, 33),

		create("ImageButton")({
			Name = "header",
			tags = { "border" },

			create("UIDragDetector")({
				DragStart = function(from: Vector2)
					previous = from
				end,
				DragContinue = function(from: Vector2)
					local delta = from - previous
					local current = Vector2.new(window.Position.X.Offset, window.Position.Y.Offset)
					local new = current + delta
					previous = from
					window.Position = UDim2.fromOffset(new.X, new.Y)
				end,
				DragEnd = function(from: Vector2)
					previous = from
				end,
			}),

			-- MouseButton1Down = function(x, y)
			-- 	dragging = true
			-- end,

			title,
			close,
		}),

		create("Frame")({
			Name = "container",

			container,

			create("ImageLabel")({
				Name = "resize",

				ImageContent = assets["images/resize_icon.svg"],

				create("UIDragDetector")({
					DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,

					DragStart = function(from: Vector2)
						previous = from
					end,
					DragContinue = function(from: Vector2)
						local delta = from - previous
						local current = Vector2.new(w, h)
						local new = current + delta
						previous = from
						w, h = new.X, new.Y
						window.Size = UDim2.fromOffset(new.X, new.Y)
					end,
					DragEnd = function(from: Vector2)
						previous = from
					end,
				}),
			}),
		}),
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
