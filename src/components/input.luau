local events = require("../events")
local create = require("../util/create")
local widget_registrar = require("../widget_registrar")

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
