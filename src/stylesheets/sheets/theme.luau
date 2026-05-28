local theme_generator = require("../../util/theme_generator")

local background = vector.create(0.1721, 0.005, 0.6)
local accent = vector.create(0.355, 0.12, 0.71)

return {
	background = theme_generator.compute_sequence(background, 0),
	accent = theme_generator.compute_sequence(accent, 0),

	text = theme_generator.generate_color(background, 0, theme_generator.CONTRAST_HIGH),
	subtext = theme_generator.generate_color(background, 0, theme_generator.CONTRAST_LOW),

	accent_text = theme_generator.generate_color(accent, 0, theme_generator.CONTRAST_HIGH),
	accent_subtext = theme_generator.generate_color(accent, 0, theme_generator.CONTRAST_LOW),

	font = Font.fromId(16658221428),
	monospace = Font.fromId(16658246179),
}
