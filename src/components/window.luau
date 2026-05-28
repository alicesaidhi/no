local assets = require("../assets")
local events = require("../events")
local stylesheets = require("../stylesheets")
local define_styles = require("../stylesheets/define_styles")
local theme = require("../stylesheets/sheets/theme")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local rule = define_styles.rule

stylesheets.append_sheet({
	rule(".nx_window")({

		rule("::UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,

			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		}),

		rule("::UIShadow")({
			Spread = UDim2.new(0, 4, 0, 4),
			BlurRadius = UDim.new(0, 16),
			Transparency = 0.9,
		}),

		rule("> GuiObject #container")({

			rule("::UIFlexItem")({
				FlexMode = Enum.UIFlexMode.Fill,
			}),

			rule("> GuiObject #children")({
				Size = UDim2.fromScale(1, 1),

				rule("::UIPadding", -10)({
					PaddingTop = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
				}),
			}),

			rule("> ImageLabel #resize")({
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(1, 1),

				ImageColor3 = theme.text,
			}),
		}),

		rule("> #header GuiObject")({
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundColor3 = theme.background(2),
			BackgroundTransparency = 0,

			rule("ImageButton")({
				AutoButtonColor = false,
			}),

			rule("GuiObject .accent")({
				BackgroundColor3 = theme.accent(0),
			}),

			rule("::UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,

				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
			}),

			rule("::UIPadding")({
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 2),
			}),

			rule("> #close ImageButton")({
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,

				rule("::UIAspectRatioConstraint")({
					AspectRatio = 1,
				}),

				rule("> #label ImageLabel")({
					Size = UDim2.fromScale(0.6, 0.6),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),

					ImageColor3 = theme.text,
					ImageContent = assets["images/close_icon.svg"],
				}),

				rule("ImageButton :hover")({
					BackgroundColor3 = Color3.new(),
					BackgroundTransparency = 0.5,

					rule("::UICorner")({
						CornerRadius = UDim.new(0, 4),
					}),
				}),

				rule("ImageButton :press")({
					BackgroundColor3 = Color3.fromHex("#ffffff"),
					BackgroundTransparency = 0.9,

					rule("::UICorner")({
						CornerRadius = UDim.new(0, 4),
					}),
				}),

				rule(":noninteractable > #label ImageLabel")({
					ImageColor3 = theme.background(-2),
				}),

				-- rule(":noninteractable")({
				-- 	TextColor3 = theme.background(-3),
				-- }),
			}),
		}),
	}),
})

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
		tags = { "nx_window", "background", "border" },

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
