local define_styles = require("@self/define_styles")
local parser = require("@self/parser")

local stylesheets = {}

local stored_sheets = {}
function stylesheets.append_sheet(stylesheet: StyleSheet)
	table.insert(stored_sheets, stylesheet)
end

function stylesheets.link(target: Instance)
	local links = {}
	for i, sheet in stored_sheets do
		links[i] = define_styles.link(target, sheet)
	end

	return links
end

stylesheets.define_styles = define_styles

return stylesheets
