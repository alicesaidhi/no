--!nocheck
local assets = require("../../assets")
local define_styles = require("../define_styles")
local theme = require("./theme")

local rule = define_styles.rule

return {
	rule("ScreenGui", -10)({
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}),

	rule("GuiObject", -10)({
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		AutoLocalize = false,
	}),

	rule(".container ::UIListLayout", -10)({
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),

	rule("ScrollingFrame .scrolling", -10)({
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),

		ScrollBarThickness = 4,

		rule("ScrollingFrame .horizontal")({
			AutomaticCanvasSize = Enum.AutomaticSize.X,
		}),
	}),

	rule(".border ::UIStroke", -10)({
		Color = theme.background(-2),
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}),

	rule("TextLabel .nx_label, TextButton .nx_label, TextBox .nx_label", -10)({
		AutomaticSize = Enum.AutomaticSize.XY,

		TextColor3 = theme.text,
		TextSize = 14,
		FontFace = theme.font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	}),

	rule("TextLabel .nx_subtext, TextButton .nx_subtext, TextBox .nx_subtext", -10)({
		AutomaticSize = Enum.AutomaticSize.XY,

		TextColor3 = theme.subtext,
		TextSize = 10,
		FontFace = theme.font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	}),

	rule("TextLabel .nx_header, TextButton .nx_header, TextBox .nx_header", -10)({
		AutomaticSize = Enum.AutomaticSize.XY,

		TextColor3 = theme.text,
		TextSize = 16,
		FontFace = theme.font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	}),

	rule("TextLabel .nx_mono, TextButton .nx_mono, TextBox .nx_mono", -9)({
		FontFace = theme.monospace,
	}),

	rule("GuiObject .accent", -10)({
		BackgroundColor3 = theme.accent(0),
		BackgroundTransparency = 0.1,

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

	rule("GuiObject .background", -10)({
		BackgroundColor3 = theme.background(0),
		BackgroundTransparency = 0,

		rule(".border ::UIStroke")({
			Color = theme.background(-2),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
	}),

	rule(".arrow_down ImageLabel", -10)({
		Size = UDim2.fromScale(1, 1),
		ImageContent = assets["images/arrow_icons.svg"],
		ImageRectSize = Vector2.new(64, 64),
		ImageRectOffset = Vector2.new(0, 0),

		rule("::UIAspectRatioConstraint")({
			AspectRatio = 1,
		}),
	}),
	rule(".arrow_right ImageLabel", -10)({
		Size = UDim2.fromScale(1, 1),
		ImageContent = assets["images/arrow_icons.svg"],
		ImageRectSize = Vector2.new(64, 64),
		ImageRectOffset = Vector2.new(64, 0),

		rule("::UIAspectRatioConstraint")({
			AspectRatio = 1,
		}),
	}),
	rule(".arrow_left ImageLabel", -10)({
		Size = UDim2.fromScale(1, 1),
		ImageContent = assets["images/arrow_icons.svg"],
		ImageRectSize = Vector2.new(64, 64),
		ImageRectOffset = Vector2.new(172, 0),

		rule("::UIAspectRatioConstraint")({
			AspectRatio = 1,
		}),
	}),
	rule(".arrow_up ImageLabel", -10)({
		Size = UDim2.fromScale(1, 1),
		ImageContent = assets["images/arrow_icons.svg"],
		ImageRectSize = Vector2.new(64, 64),
		ImageRectOffset = Vector2.new(128, 0),

		rule("::UIAspectRatioConstraint")({
			AspectRatio = 1,
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

		rule("TextLabel")({
			Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
		}),
	}),

	rule(".nx_slider_bar GuiObject")({
		Size = UDim2.new(0, 2, 1, 0),
		BackgroundTransparency = 0,
		BackgroundColor3 = theme.subtext,
		AnchorPoint = Vector2.new(0.5, 0),
		ZIndex = 2,
	}),
}
