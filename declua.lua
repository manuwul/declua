---@class Declua
---@field cmds { list: string, install: string, uninstall: string }
---@field pkgs { ensure: { installed: table<string>, uninstalled: table<string> } }
---@field list_pkgs function
---@field ensure_installed function
---@field ensure_uninstalled function

local Declua = {}
Declua.__index = Declua

function Declua:new()
	local instance = setmetatable({
		cmds = {
			list = "",
			install = "",
			uninstall = ""
		},
		pkgs = {
			ensure = {
				installed = {},
				uninstalled = {}
			}
		},
	}, self)
	return instance
end

function Declua:list_pkgs()
	local handle = io.popen(self.cmds.list)
	if (handle == nil) then return "" end
	local result = handle:read("*a")
	handle:close()
	return result
end

function Declua:ensure_installed()
	for _, value in ipairs(self.pkgs.ensure.installed) do
		os.execute(self.cmds.install .. " " .. value)
	end
end

function Declua:ensure_uninstalled()
	for _, value in ipairs(self.pkgs.ensure.uninstalled) do
		os.execute(self.cmds.uninstall .. " " .. value)
	end
end

return Declua
