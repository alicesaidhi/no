local ReplicatedStorage = game:GetService("ReplicatedStorage")

local define_styles = require("@self/define_styles")

local stylesheets = {}

local stored: { define_styles.StyleData } = {}
function stylesheets.append_sheet(stylesheet: { define_styles.StyleData })
	table.move(stylesheet, 1, #stylesheet, #stored + 1, stored)
end

function stylesheets.link(target: Instance)
	local sheet = define_styles.sheet(stored)
	sheet.Parent = target

	local link = define_styles.link(target, sheet)

	return link, sheet
end

stylesheets.define_styles = define_styles

for _, sheet in script.sheets:GetChildren() do
	local stylesheet = (require :: any)(sheet)
	if typeof(stylesheet) == "table" then
		for _, value in stylesheet do
			if typeof(value) == "table" and (value.type == "rule" or value.type == "token") then
				table.insert(stored, value)
			end
		end
	end
end

return stylesheets
