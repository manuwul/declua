---@class Declua
Declua = require("declua")
---@type Declua
---@diagnostic disable-next-line: lowercase-global
declua = declua

declua.cmds = {
	list = "pacman -Qqen",
	install = "pacman -Sq --noconfirm",
	uninstall = "pacman -Rs --noconfirm"
}

declua.pkgs.ensure = {
	installed = {
		"kmines",
		"gcc",
		"make"
	},
	uninstalled = {
		"gnome-sudoku"
	}
}
