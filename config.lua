---@class Declua
Declua = require("declua")
---@type Declua
---@diagnostic disable-next-line: lowercase-global
declua = declua


declua.pacman.enabled = true
declua.pacman.pkgs = {
	install = {
		"kmines",
		"gcc",
		"make"
	},
	uninstall = {
		"gnome-sudoku",
		"*"
	}
}
