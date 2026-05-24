local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local nx = require("@game/ReplicatedStorage/nx")
local widget_registrar = require("./nx/widget_registrar")

local screengui_widget = nx.widget("screengui", {}, nx.empty_serde)
local screengui = screengui_widget.construct(function(props: nil, scope, events)
	return nil, nil
end, function(scope, events, parent)
	local screengui = Instance.new("ScreenGui")
	screengui.Name = scope.key
	screengui:AddTag("nx_screengui")

	screengui.Parent = parent

	scope.cleanup(screengui)

	return screengui, nil
end)

local label_widget = nx.widget("label", {}, (nil :: any) :: nx.Serde<string>)
local label = label_widget.construct(function(props: string, scope, events)
	return props, nil
end, function(scope, events, parent)
	local label = Instance.new("TextLabel")
	label.Name = scope.key
	label:AddTag("nx_label")

	label.AutomaticSize = Enum.AutomaticSize.XY
	label.TextSize = 32
	label.AutoLocalize = false
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Parent = parent

	scope.cleanup(label)
	scope.on_updated_props(function(value)
		label.Text = value
	end)

	return label, nil
end)

local button_widget = nx.widget("button", {
	clicked = nx.event(),
}, (nil :: any) :: nx.Serde<string>)
local button = button_widget.construct(function(props: string, scope, events)
	local clicked = if events.clicked:poll() then true else false
	return props, { clicked = clicked }
end, function(scope, events, parent)
	local button = Instance.new("TextButton")
	button.Name = scope.key
	button:AddTag("nx_button")

	button.AutomaticSize = Enum.AutomaticSize.XY
	button.TextSize = 32
	button.AutoLocalize = false
	button.BackgroundTransparency = 1
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Parent = parent

	scope.cleanup(button)
	scope.on_updated_props(function(value)
		button.Text = value
	end)

	button.Activated:Connect(function()
		events.clicked:fire(true)
	end)

	return button, nil
end)

local root = nx.scope({ label = label, button = button, screengui = screengui })
local target = nx.target(Players.LocalPlayer.PlayerGui)

-- get_state: <T>(T?) -> (T, (T) -> ()),

local s = os.clock()
local pending_diff: any

RunService.PostSimulation:Connect(function()
	nx.set_client_fired_events(root, pending_diff)
	local _, scope = root:screengui("meow")
	if scope:button("evil", "meow").clicked then
		print("meow")
	end

	local delta = nx.get_diff_delta(root)
	nx.apply_diff(target, delta)
	pending_diff = nx.get_client_fired_events(target)
	print(pending_diff)
end)
