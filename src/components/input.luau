local events = require("../events")
local stylesheets = require("../stylesheets")
local define_styles = require("../stylesheets/define_styles")
local theme = require("../stylesheets/sheets/theme")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

local rule = define_styles.rule

stylesheets.append_sheet({
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
})

local input = widget_registrar.register(
	"input",
	{
		text_changed = events.event(),
		focused = events.event(),
		focuslost = events.event(),
	},
	(nil :: any) :: widget_registrar.Serde<{
			text: string,
			multiline: boolean,

			placeholder: string?,
			clear_on_focus: boolean?,
		}>
)

return input.construct(
	function(
		props: { text: string, multiline: boolean?, placeholder: string?, clear_on_focus: boolean? },
		scope,
		events
	)
		local interface = {}

		interface.new_text = (events.text_changed:poll() or false) :: string | false
		interface.focused = (events.focused:poll() or false) :: boolean
		interface.focuslost = (events.focuslost:poll() ~= nil) :: boolean
		interface.enterpressed = (events.focuslost:poll() == true) :: boolean

		return {
			text = props.text,
			multiline = props.multiline or false,
			placeholder = props.placeholder,
			clear_on_focus = props.clear_on_focus,
		},
			interface
	end,
	function(scope, events)
		local textbox: TextBox
		textbox = create("TextBox")({
			Name = scope.key,
			tags = { "nx_textbox", "nx_label", "background", "border" },

			Focused = function()
				events.focused:fire(true)
				textbox:AddTag("focused")
			end,
			FocusLost = function(enter)
				events.focuslost:fire(enter)
				textbox:RemoveTag("focused")
			end,
		})

		local previous = ""

		textbox:GetPropertyChangedSignal("Text"):Connect(function()
			if previous == textbox.Text then
				return
			end

			events.text_changed:fire(textbox.Text)
		end)

		scope.cleanup(textbox)
		scope.on_updated_props(function(props)
			previous = props.text
			textbox.Text = props.text
			textbox.PlaceholderText = props.placeholder or ""
			textbox.ClearTextOnFocus = props.clear_on_focus or false

			if props.multiline then
				textbox:AddTag("multiline")
			else
				textbox:RemoveTag("multiline")
			end
		end)

		return textbox, nil
	end
)
