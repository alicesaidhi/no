local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local no = require(game.ReplicatedStorage.no)

local connections = {}
local nodes = {}
local roots = {}
local diffs = {}

local function player_added(player: Player)
	local root, main = no.scope(no.base)
	nodes[player] = main
	roots[player] = root

	local count = 0
	local current_tab = "tab 1"
	local values = {}

	connections[player] = RunService.PostSimulation:Connect(function(dt)
		no.set_client_fired_events(main, diffs[player])

		table.insert(values, dt + math.random() * 0.001)
		if #values > 100 then
			table.remove(values, 1)
		end

		do
			local scope = root:window("window", {
				title = "Window",
				w = 200,
				h = 300,
			})

			scope:label("key", "hello!!!!!")
			local test = scope:button("testing", "increase count")

			if test.clicked then
				count += 1
			end
			scope:label("count", `count: {count}`)
			scope:input("input", { placeholder = "meow", text = "" })
			scope:separator("m", "bleh this sucks!!!")
			scope:label("count1", `count: {count}`)
			scope:checkbox("checked", { text = "checked", checked = true })
			scope:checkbox("unchecked", { text = "unchecked", checked = false })

			do
				local scope = scope:tabs("tabs", { options = { "tab 1", "tab 2" }, visible = current_tab })
				current_tab = scope.changed_tab or current_tab

				if current_tab == "tab 1" then
					scope:label("just", "just testing")
				elseif current_tab == "tab 2" then
					scope:label("why", "this is annoying")
				end
			end
			scope:label("thing", "meowing")

			do
				local scope = scope:collapsible("test", { name = "heartbeat graph", default = false })

				if scope.expanded then
					scope:label("timer", `time: {string.format("%.3g ms", dt * 1000)}`)
					scope:linechart("chart", {
						values = values,
						max = 1 / 30,
						min = 0,
						y_steps = 1 / 120,
						metric_unit = "s",
					})
				end
			end

			local tooltip_scope = scope:button("meow", "hi"):tooltip("tooltip", "tooltips")
			if tooltip_scope.visible then
				tooltip_scope:linechart("chart", {
					values = values,
					max = 1 / 30,
					min = 0,
					y_steps = 1 / 120,
					metric_unit = "s",
				})
			end
		end
		local delta = no.get_diff_delta(main)

		if delta then
			ReplicatedStorage.replicate_no:FireClient(player, no.compress(delta))
		end

		diffs[player] = nil
		-- no.apply_diff(target, delta)
		-- pending_diff = no.get_client_fired_events(target)
	end)
end

ReplicatedStorage.replicate_no.OnServerEvent:Connect(function(player: Player, ...)
	diffs[player] = no.decompress(...)
end)

for _, player in Players:GetPlayers() do
	player_added(player)
end

Players.PlayerAdded:Connect(player_added)
