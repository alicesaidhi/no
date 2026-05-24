local function cleanup(dumpster: { unknown })
	for _, value in dumpster do
		if typeof(value) == "function" then
			value()
		elseif typeof(value) == "Instance" then
			value:Destroy()
		elseif typeof(value) == "RBXScriptConnection" then
			value:Disconnect()
		elseif typeof(value) == "thread" then
			task.cancel(value)
		elseif typeof(value) == "table" then
			local destroy = value.destroy or value.disconnect or value.Destroy or value.Disconnect

			if destroy then
				destroy(value)
			else
				error("cannot cleanup given object")
			end
		else
			error("cannot cleanup given object")
		end
	end
end

return cleanup
