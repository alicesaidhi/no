local oklab = require("./oklab")

local LIGHT_THRESHOLD = 0.6
local STEP_SIZE_DEPTH = 0.02
local CONTRAST_LOW = 0.4
local CONTRAST_HIGH = 0.7

local function should_flip(light: number)
	return light > LIGHT_THRESHOLD
end

local function oklch_to_color3(oklch: vector)
	return oklab.linear_srgb_to_color3(oklab.oklab_to_linear_srgb(oklab.oklch_to_oklab(oklch)))
end

--- @class Theme

--[=[
Computes a new color based on the given oklch value and contrast.
This is automatically optimized for either light or dark mode.
@within Theme
@param oklch vector
@param depth number
@param contrast number
@return vector
]=]
local function compute_color(oklch: vector, depth: number, contrast: number): vector
	if should_flip(oklch.x) then
		oklch -= vector.create(contrast, 0, 0)
	else
		oklch += vector.create(contrast, 0, 0)
	end

	if should_flip(oklch.x) then
		oklch -= vector.create(depth * STEP_SIZE_DEPTH, 0, 0)
	else
		oklch += vector.create(depth * STEP_SIZE_DEPTH, 0, 0)
	end

	return oklch
end

local function obtain_color_generator(base: vector, depth: number, contrast: number)
	return oklch_to_color3(compute_color(base, depth, contrast))
end

--[=[
Generates a lazily built sequence of colors based on a set of parameters.

@within Theme
@return { [number]: () -> Color3 }
]=]
local function compute_sequence(base: vector, contrast: number)
	return function(depth: number)
		return obtain_color_generator(base, depth, contrast)
	end
end

return {
	CONTRAST_LOW = CONTRAST_LOW,
	CONTRAST_HIGH = CONTRAST_HIGH,

	compute_sequence = compute_sequence,
	generate_color = obtain_color_generator,
	compute_color = compute_color,
}
