local assets = require("../../assets")
local define_styles = require("../define_styles")
local theme = require("./theme")

local rule = define_styles.rule

return define_styles.sheet({
	rule("GuiObject")({
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	}),

	rule("ScrollingFrame .scrolling")({
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),

		ScrollBarThickness = 6,

		rule("ScrollingFrame .horizontal")({
			AutomaticCanvasSize = Enum.AutomaticSize.X,
		}),
	}),

	rule("GuiObject .accent")({
		BackgroundColor3 = theme.accent(0),
		BackgroundTransparency = 0,

		rule(">> TextLabel .nx_label")({
			TextColor3 = theme.accent_text,
		}),

		rule(">> TextLabel .nx_header")({
			TextColor3 = theme.accent_text,
		}),

		rule(".border ::UIStroke")({
			Color = theme.accent(-2),
		}),
	}),

	rule("GuiObject .background")({
		BackgroundColor3 = theme.background(0),
		BackgroundTransparency = 0,

		rule(".border ::UIStroke")({
			Color = theme.background(-2),
		}),
	}),

	rule(".border ::UIStroke")({
		Color = theme.background(-2),
	}),

	rule("TextLabel .nx_label")({
		AutomaticSize = Enum.AutomaticSize.XY,

		BackgroundTransparency = 1,

		TextColor3 = theme.text,
		TextSize = 14,
		FontFace = theme.font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	}),

	rule("TextLabel .nx_header")({
		AutomaticSize = Enum.AutomaticSize.XY,

		BackgroundTransparency = 1,

		TextColor3 = theme.text,
		TextSize = 16,
		FontFace = theme.font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	}),

	rule(".no_window")({

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
				rule("::UIPadding")({
					PaddingTop = UDim.new(0, 2),
					PaddingLeft = UDim.new(0, 2),
					PaddingRight = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2),
				}),

				rule("::UIListLayout")({
					Padding = UDim.new(0, 2),
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

			rule("::UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,

				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
			}),

			rule("::UIPadding")({
				PaddingLeft = UDim.new(0, 2),
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

				rule("ImageButton :pressed")({
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
