export type function Combine(root: type, a: type, b: type, c: type, d: type, e: type, f: type, g: type)
	local function annoying(root: type, ...: type)
		assert(root.tag == "table")
		local copy = types.newtable(root:properties())

		for i = 1, select("#", ...) do
			local t: type = select(i, ...)
			if t.tag ~= "table" then
				continue
			end

			for key, value in t:properties() do
				copy:setreadproperty(key, value.read)
				copy:setwriteproperty(key, value.write)
			end
		end

		return copy
	end

	return annoying(root, a, b, c, d, e, f, g)
end

export type function CombineTwo(root: type, a: type)
	local function annoying(root: type, ...: type)
		assert(root.tag == "table")
		local copy = types.copy(root)

		for i = 1, select("#", ...) do
			local t: type = select(i, ...)
			if t.tag ~= "table" then
				continue
			end

			for key, value in t:properties() do
				copy:setreadproperty(key, value.read)
				copy:setwriteproperty(key, value.write)
			end
		end

		return copy
	end

	return annoying(root, a)
end

return {}
