local theme_generator = require("../../util/theme_generator")

local background = vector.create(0.1721, 0.005, 0.6)
local accent = vector.create(0.405, 0.21, 0.71)

return {
	background = theme_generator.compute_sequence(background, 0),
	accent = theme_generator.compute_sequence(accent, 0),

	text = theme_generator.generate_color(background, 0, theme_generator.CONTRAST_HIGH),
	subtext = theme_generator.generate_color(background, 0, theme_generator.CONTRAST_HIGH),

	accent_text = theme_generator.generate_color(accent, 0, theme_generator.CONTRAST_HIGH),
	accent_subtext = theme_generator.generate_color(accent, 0, theme_generator.CONTRAST_HIGH),

	font = Font.fromId(16658221428),
	monospace = Font.fromId(16658246179),
}
