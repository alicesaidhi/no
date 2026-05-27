--!nocheck
local assets = require("../../assets")
local define_styles = require("../define_styles")
local theme = require("./theme")

local rule = define_styles.rule

return define_styles.sheet({
	rule("GuiObject", -10)({
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	}),

	rule(".container ::UIPadding")({
		PaddingTop = UDim.new(0, 2),
		PaddingLeft = UDim.new(0, 2),
		PaddingRight = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 2),
	}),

	rule(".container ::UIListLayout")({
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),

	rule("ScrollingFrame .scrolling")({
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),

		ScrollBarThickness = 6,

		rule("ScrollingFrame .horizontal")({
			AutomaticCanvasSize = Enum.AutomaticSize.X,
		}),
	}),

	rule(".border ::UIStroke")({
		Color = theme.background(-2),
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}),

	rule("TextLabel .nx_label, TextButton .nx_label, TextBox .nx_label")({
		AutomaticSize = Enum.AutomaticSize.XY,

		TextColor3 = theme.text,
		TextSize = 14,
		FontFace = theme.font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	}),

	rule("TextLabel .nx_header, TextButton .nx_header, TextBox .nx_header")({
		AutomaticSize = Enum.AutomaticSize.XY,

		TextColor3 = theme.text,
		TextSize = 16,
		FontFace = theme.font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	}),

	rule("GuiObject .accent")({
		BackgroundColor3 = theme.accent(0),
		BackgroundTransparency = 0,

		rule(">> TextLabel .nx_label, >> TextButton .nx_label")({
			TextColor3 = theme.accent_text,
		}),

		rule(">> TextLabel .nx_header, >> TextButton .nx_label")({
			TextColor3 = theme.accent_text,
		}),

		rule(".border ::UIStroke")({
			Color = theme.accent(-2),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
	}),

	rule("GuiObject .background")({
		BackgroundColor3 = theme.background(0),
		BackgroundTransparency = 0,

		rule(".border ::UIStroke")({
			Color = theme.background(-2),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
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
				Size = UDim2.fromScale(1, 1),

				rule("::UIPadding")({
					PaddingTop = UDim.new(0, 2),
					PaddingLeft = UDim.new(0, 2),
					PaddingRight = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2),
				}),

				rule("::UIListLayout")({
					Padding = UDim.new(0, 2),
					SortOrder = Enum.SortOrder.LayoutOrder,
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

	rule(".nx_button GuiObject")({
		Size = UDim2.fromOffset(40, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = theme.background(5),
		BackgroundTransparency = 0,

		rule("TextButton")({
			AutoButtonColor = false,
			TextXAlignment = Enum.TextXAlignment.Center,
		}),

		rule("::UIPadding")({
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
		}),

		rule("::UICorner")({
			CornerRadius = UDim.new(0, 2),
		}),

		rule("GuiObject :hover")({
			BackgroundColor3 = theme.background(6),
		}),
		rule("GuiObject :press")({
			BackgroundColor3 = theme.background(3),
		}),

		rule("GuiObject .accent")({
			BackgroundColor3 = theme.accent(3),

			rule("GuiObject :hover")({
				BackgroundColor3 = theme.accent(4),
			}),
			rule("GuiObject :press")({
				BackgroundColor3 = theme.accent(2),
			}),
		}),
	}),

	rule(".nx_textbox TextBox")({
		Size = UDim2.fromOffset(100, 18),
		PlaceholderColor3 = theme.subtext,
		TextWrapped = false,

		AutomaticSize = Enum.AutomaticSize.None,
		ClipsDescendants = true,

		rule(".background TextBox", 10)({
			BackgroundColor3 = theme.background(-2),
		}),

		rule(".accent TextBox", 10)({
			BackgroundColor3 = theme.accent(-3),
		}),

		rule("::UIPadding")({
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
		}),

		rule("::UICorner")({
			CornerRadius = UDim.new(0, 2),
		}),

		rule(".focused ::UIStroke", 100)({
			Color = theme.accent(0),
		}),

		rule("TextBox .multiline")({
			AutomaticSize = Enum.AutomaticSize.Y,
			MultiLine = true,
		}),
	}),

	rule(".separator GuiObject")({
		Size = UDim2.new(1, 0, 0, 12),

		rule("> TextLabel .nx_label")({
			Position = UDim2.fromOffset(8, 0),
			TextColor3 = theme.subtext,

			rule("::UIPadding")({
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
			}),
		}),

		rule("> #decoration GuiObject")({
			Position = UDim2.new(0, 0, 0.5, 2),
			Size = UDim2.new(1, 0, 0, 1),
			AnchorPoint = Vector2.new(0, 0.5),

			BackgroundColor3 = theme.background(4),
			BackgroundTransparency = 0,
		}),
	}),

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

	rule(".nx_checkbox ImageButton")({
		AutomaticSize = Enum.AutomaticSize.XY,

		Size = UDim2.fromOffset(16, 16),

		rule("::UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 4),
		}),

		rule("> #icon ImageLabel")({
			Size = UDim2.fromOffset(12, 12),
			ScaleType = Enum.ScaleType.Fit,
			Image = "rbxassetid://100188624502987",
			ImageTransparency = 1,
			BackgroundTransparency = 0,
			BackgroundColor3 = theme.background(-2),

			rule("::UICorner")({
				CornerRadius = UDim.new(0, 2),
			}),
			rule("::UIStroke")({
				Color = theme.background(-6),
			}),
		}),

		rule(":hover > #icon ::UIStroke")({
			Color = theme.accent(3),
		}),

		rule(".checked > #icon ImageLabel")({
			ImageTransparency = 0,
			BackgroundColor3 = theme.accent(2),

			rule("::UIStroke")({
				Color = theme.accent(-3),
			}),
		}),
	}),

	rule(".nx_tabs GuiObject")({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		rule("::UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		rule("::UIPadding")({
			PaddingTop = UDim.new(0, 2),
		}),

		rule("> GuiObject #tabs")({
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 0,
			ZIndex = 100,

			rule("::UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 1),
			}),
		}),

		rule("> GuiObject #container")({
			Size = UDim2.fromScale(1, 0),
			LayoutOrder = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
		}),
	}),

	rule(".nx_tab GuiObject")({
		Size = UDim2.fromOffset(40, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = theme.background(2),
		BackgroundTransparency = 0,

		rule("TextButton")({
			AutoButtonColor = false,
			TextXAlignment = Enum.TextXAlignment.Center,
		}),

		rule("::UIPadding")({
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
		}),

		rule("::UICorner")({
			TopLeftRadius = UDim.new(0, 2),
			TopRightRadius = UDim.new(0, 2),
			BottomLeftRadius = UDim.new(0, 0),
			BottomRightRadius = UDim.new(0, 0),
		}),

		rule("GuiObject :hover")({
			BackgroundColor3 = theme.background(3),
		}),
		rule("GuiObject :press")({
			BackgroundColor3 = theme.background(1),
		}),

		rule(".selected GuiObject")({
			BackgroundColor3 = theme.accent(0),

			rule("GuiObject :hover")({
				BackgroundColor3 = theme.accent(1),
			}),
			rule("GuiObject :press")({
				BackgroundColor3 = theme.accent(-1),
			}),
		}),
	}),

	rule(".nx_slider_base GuiObject")({
		Size = UDim2.new(0, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.X,

		rule("::UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),

		rule("::UIPadding")({
			PaddingLeft = UDim.new(0, 4),
		}),
	}),

	rule(".nx_slider_holder GuiObject")({
		Size = UDim2.new(0, 100, 1, 0),
		BackgroundTransparency = 0,
		BackgroundColor3 = theme.background(5),

		rule("::UICorner")({
			CornerRadius = UDim.new(0, 4),
		}),
	}),

	rule(".nx_slider_bar GuiObject")({
		Size = UDim2.new(0, 2, 1, 0),
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		AnchorPoint = Vector2.new(0.5, 0),
		ZIndex = 2,
	}),
})
