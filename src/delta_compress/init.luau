local Apply = require("@self/Apply")
local Diff = require("@self/Diff")

--[=[
	@class DeltaCompress
]=]

return {
	diffImmutable = Diff.diffImmutable,
	diffMutable = Diff.diffMutable,
	applyImmutable = Apply.applyImmutable,
	applyMutable = Apply.applyMutable,
}
