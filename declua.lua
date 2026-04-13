---@alias PkgMgr {
--- 	enabled: boolean,
--- 	cmds: {
--- 		list: string,
--- 		install: string,
--- 		uninstall: string },
---		pkgs: {
---			install:   string[],
---			uninstall: string[] } }

---@class Declua
---
---@field pacman PkgMgr
---
---@field list_pkgs function
---@field ensure_installed function
---@field ensure_uninstalled function

local Declua = {}
Declua.__index = Declua



function Declua:new()
	local instance = setmetatable({}, self)

	instance.pacman = {
		enabled = false,
		cmds = {
			list      = "pacman -Qqen",
			install   = "pacman -Sq --noconfirm",
			uninstall = "pacman -Rs --noconfirm"
			},
		pkgs = {
			install   = {},
			uninstall = {}
		}
	}

	return instance
end

---@deprecated
function Declua:list_pkgs()
	local handle = io.popen(self.cmds.list)
	if (handle == nil) then return "" end
	local result = handle:read("*a")
	handle:close()
	return result
end

function Declua:ensure_installed()
	print("--- ENSURE INSTALLED ---")
	for pkg_mgr_name, pkg_mgr in pairs(self) do
		if type(pkg_mgr) == "table" and pkg_mgr.enabled ~= nil then
			print("[INFO]: ENSURING " .. pkg_mgr_name .. " PACKAGES ARE INSTALLED")
			for _, pkg in ipairs(pkg_mgr.pkgs.install) do
				print("[INFO]: ensuring " .. pkg .. " is installed")
				local handle = io.popen(pkg_mgr.cmds.install .. " " .. pkg)
				if (handle == nil) then
					print("[ERROR]: CANNOT OPEN CMD HANDLE")
					goto continue
				end
				local _ = handle:read("*a")
				local success, reason, _ = handle:close()
				if (not success) then
					print("[ERROR]: CANNOT INSTALL PKG: " .. reason)
				end
				::continue::
			end
		end
	end
	print("--- DONE ---")
end

function Declua:ensure_uninstalled()
	print("--- ENSURE UNINSTALLED ---")
	for pkg_mgr_name, pkg_mgr in pairs(self) do
		if type(pkg_mgr) == "table" and pkg_mgr.enabled ~= nil then
			print("[INFO]: ENSURING " .. pkg_mgr_name .. " PACKAGES ARE NOT INSTALLED")
			for _, pkg in ipairs(pkg_mgr.pkgs.uninstall) do
				print("[INFO]: ensuring " .. pkg .. " is not installed")
				local handle = io.popen(pkg_mgr.cmds.uninstall .. " " .. pkg)
				if (handle == nil) then
					print("[ERROR]: CANNOT OPEN CMD HANDLE")
					goto continue
				end
				local _ = handle:read("*a")
				local success, reason, _ = handle:close()
				if (not success) then
					print("[ERROR]: CANNOT UNINSTALL PKG: " .. reason)
				end
				::continue::
			end
		end
	end
	print("--- DONE ---")
end

return Declua
