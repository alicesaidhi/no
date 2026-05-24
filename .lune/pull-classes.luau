local net = require("@lune/net")
local serde = require("@lune/serde")
local fs = require("@lune/fs")

local API_DUMP_LINK = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json"

local result = serde.decode(
	"json",
	net.request({
		url = API_DUMP_LINK,
	}).body
)

local txt = { "export type Classes = {" }

for _, class in result.Classes do
	local name = class.Name
	if string.find(name, " ") then
		continue
	end
	table.insert(txt, `\t{name}: {name},`)
end

table.insert(txt, "}")
table.insert(txt, "")
table.insert(txt, "return {}")

fs.writeFile("src/stylesheets/classes.luau", table.concat(txt, "\n"))
