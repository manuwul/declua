---@class Declua
Declua = require("declua")
---@type Declua
---@diagnostic disable-next-line: lowercase-global
declua = declua

declua.logs.level = declua.logs.INFO

declua.pacman.enabled = true
declua.pacman.pkgs.install = {
	gcc = true,
	make = true,
	rlwrap = true
}
declua.pacman.pkgs.uninstall = {
	["gnome-sudoku"] = true,
	cosmic = true
}
