local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local no = require("@game/ReplicatedStorage/no")
local widget_registrar = require("./no/widget_registrar")

local screengui = Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui)

local target = no.target(screengui)

ReplicatedStorage.replicate_no.OnClientEvent:Connect(function(...)
	local diff = no.decompress(...)

	no.apply_diff(target, diff)
	local events = no.get_client_fired_events(target)
	if events then
		ReplicatedStorage.replicate_no:FireServer(no.compress(events))
	end
end)
