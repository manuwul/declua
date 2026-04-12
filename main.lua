#!/usr/bin/env lua

local env = { declua = require("declua"):new() }

setmetatable(env, {
	__index = _G,
})

loadfile("./config.lua", "t", env)()

env.declua:ensure_installed()
env.declua:ensure_uninstalled()
