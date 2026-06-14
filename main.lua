#!/usr/bin/env lua

local env = {
	declua = require("declua"):new()
}

setmetatable(env, {
	__index = _G,
})

loadfile("./config.lua", "t", env)()

env.declua:prepare()
env.declua:install()
env.declua:uninstall()
