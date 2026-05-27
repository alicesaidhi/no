--!nocheck
local assets = require("../../assets")
local define_styles = require("../define_styles")
local theme = require("./theme")

local rule = define_styles.rule

return {
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

		ScrollBarThickness = 6,

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
}
