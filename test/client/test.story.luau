local RunService = game:GetService("RunService")

return function(target)
	local no = require(game.ReplicatedStorage.no)

	local root, main = no.scope(no.base)
	local target = no.target(target)

	local pending_diff: any

	local count = 0
	local slider_count = 5
	local current_tab = "tab 1"
	local values = {}
	local c = RunService.PreRender:Connect(function(dt)
		no.set_client_fired_events(main, pending_diff)
		table.insert(values, dt)
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
			scope:dropdown("dropdown", { set_to = "grapejuice", options = { "meow", "grapejuice", "hii" } })

			local slider = scope:slider("slider", { min = 0, max = 50, step = 10, value = slider_count })
			slider_count = slider.value
			scope:label("slider_value", `slider: {slider.value}`)

			if scope:button("", "increment").clicked then
				slider_count += 1
			end

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
			delta = no.decompress(no.compress(delta))
		end

		no.apply_diff(target, delta)
		pending_diff = no.get_client_fired_events(target)
	end)

	return function()
		c:Disconnect()
		no.clear_all()
	end
end
