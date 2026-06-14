--- @alias PkgMgr {
--- enabled: boolean,
--- cmds: {
--- 	list: 		string,
--- 	install: 	string,
--- 	uninstall: 	string },
--- pkgs: {
--- 	install: 	table<string, boolean>,
--- 	uninstall: 	table<string, boolean>,
--- 	listed: 	table<string, boolean> } }

--- @class Declua
---
--- @field pkg_mgrs table<string, PkgMgr>
--- @field logs { ERROR: number, INFO: number, level: number }
---
--- @field prepare fun(self: Declua) List packages and prepare to install/uninstall
--- @field install fun(self: Declua) Install packages
--- @field uninstall fun(self: Declua) Uninstall packages

local Declua = {}
Declua.__index = Declua

function Declua:new()
	--- @type Declua
	local instance = setmetatable({}, self)

	instance.logs = {
		INFO = 0,
		ERROR = 1,

		level = 0
	}

	instance.pkg_mgrs = {
		pacman = {
			enabled = false,
			cmds = {
				list      = "sudo pacman -Qqen",
				install   = "sudo pacman -Sq --noconfirm",
				uninstall = "sudo pacman -Rns --noconfirm"
			},
			pkgs = {
				list      = {},
				install   = {},
				uninstall = {}
			}
		}
	}
	return instance
end

function Declua:log(level, msg)
	if level < self.logs.level then
		return
	end

	if level == self.logs.ERROR then
		io.stderr:write("[ERROR] " .. msg .. "\n")
		io.stderr:flush()
	end

	if level == self.logs.INFO then
		io.stderr:write("[INFO] " .. msg .. "\n")
		io.stderr:flush()
	end
end

function Declua:list_pkgs(pkg_mgr)
	if self.pkg_mgrs[pkg_mgr] == nil then
		self:log(self.logs.ERROR, pkg_mgr .. " PACKAGE MANAGER NOT CONFIGURED")
		return ""
	end

	local handle = io.popen(self.pkg_mgrs[pkg_mgr].cmds.list)
	if handle == nil then
		self:log(self.logs.ERROR, "CANNOT OPEN HANDLE TO LIST " .. pkg_mgr)
		return ""
	end
	local result = handle:read("a")
	handle:close()
	return result
end

function Declua:list()
	self:log(self.logs.INFO, "== LISTING ==")
	for pkg_mgr_name, pkg_mgr in pairs(self.pkg_mgrs) do
		if not pkg_mgr.enabled then
			goto continue
		end
		self:log(self.logs.INFO, "LISTING " .. pkg_mgr_name)
		for pkg in self:list_pkgs(pkg_mgr_name):gmatch("[^\n]+") do
			pkg_mgr.pkgs.list[pkg] = true
		end
		::continue::
	end
end

function Declua:install_pkg(pkg_mgr, pkg)
	self:log(self.logs.INFO, "INSTALLING " .. pkg)
	if self.pkg_mgrs[pkg_mgr] == nil then
		self:log(self.logs.ERROR, pkg_mgr .. " PACKAGE MANAGER NOT CONFIGURED")
		return
	end

	local handle = io.popen(self.pkg_mgrs[pkg_mgr].cmds.install .. " " .. pkg)
	if handle == nil then
		self:log(self.logs.ERROR, "CANNOT OPEN HANDLE TO INSTALL " .. pkg_mgr)
		return
	end

	local _ = handle:read("*a")
	local success, reason, _ = handle:close()
	if not success then
		self:log(self.logs.ERROR, "CANNOT INSTALL PKG: " .. reason)
	end
end

function Declua:uninstall_pkg(pkg_mgr, pkg)
	self:log(self.logs.INFO, "UNINSTALLING " .. pkg)
	if self.pkg_mgrs[pkg_mgr] == nil then
		self:log(self.logs.ERROR, pkg_mgr .. " PACKAGE MANAGER NOT CONFIGURED")
		return
	end

	local handle = io.popen(self.pkg_mgrs[pkg_mgr].cmds.uninstall .. " " .. pkg)
	if handle == nil then
		self:log(self.logs.ERROR, "CANNOT OPEN HANDLE TO UNINSTALL " .. pkg_mgr)
		return
	end
	local _ = handle:read("*a")
	local success, reason, _ = handle:close()
	if not success then
		self:log(self.logs.ERROR, "CANNOT UNINSTALL PKG: " .. reason)
	end
end

function Declua:prepare_mgr(pkg_mgr)
	for pkg, _ in pairs(self.pkg_mgrs[pkg_mgr].pkgs.list) do
		self.pkg_mgrs[pkg_mgr].pkgs.install[pkg] = nil
	end
end

function Declua:prepare()
	self:list()
	for pkg_mgr_name, pkg_mgr in pairs(self.pkg_mgrs) do
		if not pkg_mgr.enabled then
			goto continue
		end

		self:prepare_mgr(pkg_mgr_name)
	    ::continue::
	end
end

function Declua:install()
	self:log(self.logs.INFO, "== INSTALLING ==")
	for pkg_mgr_name, pkg_mgr in pairs(self.pkg_mgrs) do
		if not pkg_mgr.enabled then
			goto continue
		end
		self:log(self.logs.INFO, "INSTALLING WITH " .. pkg_mgr_name)
		for pkg, status in pairs(pkg_mgr.pkgs.install) do
			if status == true then
				self:install_pkg(pkg_mgr_name, pkg)
			end
		end
		::continue::
	end
end

function Declua:uninstall()
	self:log(self.logs.INFO, "== UNINSTALLING ==")
	for pkg_mgr_name, pkg_mgr in pairs(self.pkg_mgrs) do
		if not pkg_mgr.enabled then
			goto continue
		end
		self:log(self.logs.INFO, "UNINSTALLING WITH " .. pkg_mgr_name)
		for pkg, status in pairs(pkg_mgr.pkgs.uninstall) do
			if status == true then
				self:uninstall_pkg(pkg_mgr_name, pkg)
			end
		end
		::continue::
	end
end

return Declua
