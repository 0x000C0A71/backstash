# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A meta package to install most of my desktop setup"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND="
	app-admin/sudo
	app-editors/sublime-text
	app-editors/vim
	app-misc/neofetch
	app-portage/gentoolkit
	app-shells/zsh
	gnome-extra/polkit-gnome
	gui-apps/grim
	gui-apps/hyprpaper
	gui-apps/slurp
	gnome-base/nautilus
	gui-apps/waybar
	gui-apps/wl-clipboard
	gui-apps/wofi
	gui-libs/libadwaita
	gui-libs/xdg-desktop-portal-hyprland
	gui-wm/hyprland
	media-fonts/corefonts
	media-fonts/fonts-meta
	media-fonts/inter
	media-fonts/nerd-fonts
	media-fonts/noto
	media-fonts/noto-cjk
	media-fonts/noto-emoji
	media-fonts/source-code-pro
	sys-process/btop
	x11-misc/dunst
	x11-terms/kitty
	x11-themes/gnome-themes-standard
"