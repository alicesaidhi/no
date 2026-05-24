local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local no = require("@game/ReplicatedStorage/no")
local widget_registrar = require("./no/widget_registrar")

local root = no.scope(no.base)
local screengui = Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui)

local target = no.target(screengui)

-- get_state: <T>(T?) -> (T, (T) -> ()),

local s = os.clock()
local pending_diff: any

RunService.PostSimulation:Connect(function()
	no.set_client_fired_events(root, pending_diff)

	do
		local _, scope = root:window("window", {
			title = "Window",
			w = 200,
			h = 300,
		})

		scope:label("key", "hello!!!!!")
	end

	local delta = no.get_diff_delta(root)
	no.apply_diff(target, delta)
	pending_diff = no.get_client_fired_events(target)
end)
