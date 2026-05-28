local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local no = require("@game/ReplicatedStorage/no")
local widget_registrar = require("./no/widget_registrar")

local screengui = Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui)
screengui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local target = no.target(screengui)

ReplicatedStorage.replicate_no.OnClientEvent:Connect(function(...)
	local diff = no.decompress(...)

	no.apply_diff(target, diff)
end)

RunService.PostSimulation:Connect(function(dt)
	local events = no.get_client_fired_events(target)
	if events then
		ReplicatedStorage.replicate_no:FireServer(no.compress(events))
	end
end)
