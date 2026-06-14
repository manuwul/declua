---@class Declua
Declua = require("declua")
---@type Declua
---@diagnostic disable-next-line: lowercase-global
declua = declua

declua.logs.level = declua.logs.INFO

declua.pkg_mgrs.pacman.enabled = true
declua.pkg_mgrs.pacman.pkgs.install = {
	gcc = true,
	make = true,
	rlwrap = true,
	["gnome-sudoku"] = true
}
declua.pkg_mgrs.pacman.pkgs.uninstall = {
	["gnome-sudoku"] = true,
	cosmic = true
}
