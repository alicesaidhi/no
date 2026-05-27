--!nocheck
local assets = require("../../assets")
local define_styles = require("../define_styles")
local theme = require("./theme")

local rule = define_styles.rule

return {
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

	rule("TextLabel .nx_subtext, TextButton .nx_subtext, TextBox .nx_subtext")({
		AutomaticSize = Enum.AutomaticSize.XY,

		TextColor3 = theme.subtext,
		TextSize = 10,
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

	rule("TextLabel .nx_mono, TextButton .nx_mono, TextBox .nx_mono")({
		FontFace = theme.monospace,
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

	rule(".arrow_down ImageLabel")({
		Size = UDim2.fromScale(1, 1),
		ImageContent = assets["images/arrow_icons.svg"],
		ImageRectSize = Vector2.new(64, 64),
		ImageRectOffset = Vector2.new(0, 0),

		rule("::UIAspectRatioConstraint")({
			AspectRatio = 1,
		}),
	}),
	rule(".arrow_left ImageLabel")({
		Size = UDim2.fromScale(1, 1),
		ImageContent = assets["images/arrow_icons.svg"],
		ImageRectSize = Vector2.new(64, 64),
		ImageRectOffset = Vector2.new(64, 0),

		rule("::UIAspectRatioConstraint")({
			AspectRatio = 1,
		}),
	}),
	rule(".arrow_right ImageLabel")({
		Size = UDim2.fromScale(1, 1),
		ImageContent = assets["images/arrow_icons.svg"],
		ImageRectSize = Vector2.new(64, 64),
		ImageRectOffset = Vector2.new(172, 0),

		rule("::UIAspectRatioConstraint")({
			AspectRatio = 1,
		}),
	}),
	rule(".arrow_up ImageLabel")({
		Size = UDim2.fromScale(1, 1),
		ImageContent = assets["images/arrow_icons.svg"],
		ImageRectSize = Vector2.new(64, 64),
		ImageRectOffset = Vector2.new(128, 0),

		rule("::UIAspectRatioConstraint")({
			AspectRatio = 1,
		}),
	}),
}
