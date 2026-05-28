local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local stdio = require("@lune/stdio")

local function gen_assets(upload_target: ("cloud" | "studio")?)
	local api_key = fs.readFile(".secret/asphalt")
	assert(api_key, "missing asphalt secret")

	if not upload_target then
		local choice = stdio.prompt("select", "select upload target", { "cloud", "studio" })
		upload_target = if choice == 1 then "cloud" else "studio"
	end

	assert(upload_target)

	process.exec(
		"asphalt",
		{ "sync", upload_target },
		{ stdio = "forward", env = { ASPHALT_API_KEY = api_key } } :: process.ExecOptions
	)

	fs.writeFile("assets/assets.luau", fs.readFile("assets/assets.luau"):gsub("rbxasset://rbxasset://", "rbxasset://"))

	local fn = luau.load(fs.readFile("assets/assets.luau"), {
		injectGlobals = true,
		environment = {
			Content = {
				fromUri = function(uri)
					return {
						uri = uri,
					}
				end,
			},
		},
	})

	local assets = fn()
	local assets_as_array = {}

	for key in assets do
		table.insert(assets_as_array, key)
	end
end

return gen_assets
