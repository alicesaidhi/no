local events = require("../../events")
local widget_registrar = require("../../widget_registrar")

local button = widget_registrar.register("nx_button", { click = events.event() })
