---@alias PkgMgr {
--- 	enabled: boolean,
--- 	cmds: {
--- 		list: string,
--- 		install: string,
--- 		uninstall: string },
---		pkgs: {
---			listed:    table<string, boolean>,
---			install:   table<string, boolean>,
---			uninstall: table<string, boolean> } }

---@class Declua
---
---@field pacman PkgMgr
---@field logs { ERROR: number, INFO: number, level: number }
---
---@field list_pkgs function
---@field ensure_installed function
---@field ensure_uninstalled function

local Declua = {}
Declua.__index = Declua

function Declua:new()
	local instance = setmetatable({}, self)

	instance.logs = {
		INFO = 0,
		ERROR = 1,
		level = 0
	}

	instance.pacman = {
		enabled = false,
		cmds = {
			list      = "pacman -Qqen",
			install   = "pacman -Sq --noconfirm",
			uninstall = "pacman -Rns --noconfirm"
			},
		pkgs = {
			listed    = {},
			install   = {},
			uninstall = {}
		}
	}

	return instance
end

function Declua:log(level, msg)
	if (level < self.logs.level) then
		return
	end

	if (level == self.logs.ERR) then
		io.stderr:write("[ERROR] " .. msg .. "\n")
	end
	if (level == self.logs.INFO) then
		io.stderr:write("[INFO] " .. msg .. "\n")
	end
end

-- done i think
function Declua:list_pkgs(pkg_mgr)
	local handle = io.popen(self[pkg_mgr].cmds.list)
	if (handle == nil) then return "" end
	local result = handle:read("*a")
	handle:close()
	return result
end

-- also done
function Declua:list_all()
	print("!!! LISTING INSTALLED PACKAGES !!!")
	for pkg_mgr_name, pkg_mgr in pairs(self) do
		if type(pkg_mgr) == "table" and pkg_mgr.enabled then
			self:log(self.logs.INFO, "LISTING " .. pkg_mgr_name)
			for pkg in self:list_pkgs(pkg_mgr_name):gmatch("[^\r\n]+") do
				pkg_mgr.pkgs.listed[pkg] = true
			end
		end
	end
end

function Declua:install(pkg_mgr, pkg)
	self:log(self.logs.INFO, "installing " .. pkg)
	local handle = io.popen(pkg_mgr.cmds.install .. " " .. pkg)
	if (handle == nil) then
		self:log(self.logs.ERROR, "CANNOT OPEN CMD HANDLE")
		return
	end
	local _ = handle:read("*a")
	local success, reason, _ = handle:close()
	if (not success) then
		self:log(self.logs.ERROR, "CANNOT INSTALL PKG: " .. reason)
	end
end

function Declua:ensure_installed()
	print("!!! ENSURE INSTALLED PACKAGES !!!")
	for pkg_mgr_name, pkg_mgr in pairs(self) do
		if type(pkg_mgr) == "table" and pkg_mgr.enabled then
			self:log(self.logs.INFO, "USING " .. pkg_mgr_name)
			for pkg, status in pairs(pkg_mgr.pkgs.install) do
				if (status) then
					self:install(pkg_mgr, pkg)
				else
					self:log(self.logs.INFO, "skipping " .. pkg)
				end
			end
		end
	end
end

function Declua:uninstall(pkg_mgr, pkg)
	self:log(self.logs.INFO, "uninstalling " .. pkg)
	local handle = io.popen(pkg_mgr.cmds.uninstall .. " " .. pkg)
	if (handle == nil) then
		self:log(self.logs.ERROR, "CANNOT OPEN CMD HANDLE")
		return
	end
	local _ = handle:read("*a")
	local success, reason, _ = handle:close()
	if (not success) then
		self:log(self.logs.ERROR, "CANNOT UNINSTALL PKG " .. reason)
	end
end

function Declua:ensure_uninstalled()
	print("!!! ENSURE UNINSTALLED PACKAGES !!!")
	for pkg_mgr_name, pkg_mgr in pairs(self) do
		if type(pkg_mgr) == "table" and pkg_mgr.enabled then
			self:log(self.logs.INFO, "USING " .. pkg_mgr_name)
			for pkg, status in pairs(pkg_mgr.pkgs.uninstall) do
				if (status) then
					if (pkg == "*") then
						for pkg_i in self.list_pkgs(pkg_mgr_name):gmatch("[^\r\n]+") do
    						if (not pkg_mgr.pkgs.install[pkg_i]) then
    							self:uninstall(pkg_mgr, pkg_i)
							end
						end
					end
					self:uninstall(pkg_mgr, pkg)
				else
					self:log(self.logs.INFO, "skipping " .. pkg)
				end
			end
		end
	end
end

return Declua
