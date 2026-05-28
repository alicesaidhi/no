local stylesheets = require("../stylesheets")
local define_styles = require("../stylesheets/define_styles")
local theme = require("../stylesheets/sheets/theme")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local rule = define_styles.rule

stylesheets.append_sheet({
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
})

local separator = widget_registrar.register("nx_separator", {}, (nil :: any) :: widget_registrar.Serde<string>)

return separator.construct(function(props: string, scope, events)
	return props, nil
end, function(scope, events, parent)
	local label = create("TextLabel")({
		tags = { "nx_label", "background" },
	})

	local separator = create("Frame")({
		Name = scope.key,
		tags = { "separator" },

		create("Frame")({
			Name = "decoration",
		}),

		label,
	})

	scope.cleanup(separator)
	scope.on_updated_props(function(value)
		label.Text = value
	end)

	return separator, nil
end)
