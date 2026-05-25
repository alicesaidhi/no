local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local no = require("@game/ReplicatedStorage/no")
local widget_registrar = require("./no/widget_registrar")

local root, main = no.scope(no.base)
local screengui = Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui)

local target = no.target(screengui)

-- get_state: <T>(T?) -> (T, (T) -> ()),

local s = os.clock()
local pending_diff: any

RunService.PostSimulation:Connect(function()
	no.set_client_fired_events(main, pending_diff)
	-- do
	-- 	local scope = root:window("window", {
	-- 		title = "Window",
	-- 		w = 200,
	-- 		h = 300,
	-- 	})

	-- 	local scope = scope:tabs("test", {
	-- 		options = { "tab 1" },
	-- 		visible = "tab 1",
	-- 	})

	-- 	scope:button("meow", "testing..")
	-- 	scope:label("key", "hello!!!!!")
	-- end

	local delta = no.get_diff_delta(main)
	no.apply_diff(target, delta)
	pending_diff = no.get_client_fired_events(target)
end)
