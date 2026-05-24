local RunService = game:GetService("RunService")

return function(target)
	local no = require(game.ReplicatedStorage.no)

	local root = no.scope(no.base)
	local target = no.target(target)

	local pending_diff: any

	local c = RunService.PreRender:Connect(function()
		no.set_client_fired_events(root, pending_diff)

		do
			local _, scope = root:window("window", {
				title = "Window",
				w = 200,
				h = 300,
			})

			scope:label("key", "hello!!!!!")
		end
		do
			local _, scope = root:window("window2", {
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

	return function()
		c:Disconnect()
		no.clear_all()
	end
end
