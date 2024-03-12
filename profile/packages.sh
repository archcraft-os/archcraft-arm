#!/usr/bin/env bash

## Copyright (C) 2020-2024 Aditya Shakya <adi1090x@gmail.com>
##
## Packages Required For Archcraft ARM Installation
##
## Do not deleted any package listed here. If you want to add your packages, Add them at the end of the list.

## ---------------------------------------------------------

# List of packages
_failed_to_install=()
_packages=(
		  # Splash Screen
		  plymouth
		  archcraft-plymouth-theme
		  
		  # Xorg Server
		  xorg
		  
		  # Networking
		  networkmanager
		  networkmanager-openconnect
		  networkmanager-openvpn
		  networkmanager-pptp
		  networkmanager-strongswan
		  networkmanager-vpnc
		  network-manager-sstp
		  nm-connection-editor
		  network-manager-applet
		  modemmanager
		  usb_modeswitch
		  
		  # Bluetooth
		  bluez
		  bluez-utils
		  blueman
		  
		  # Audio
		  pipewire
		  wireplumber
		  pipewire-alsa
		  pipewire-pulse
		  pipewire-jack
		  pulsemixer
		  pavucontrol
		  gst-plugin-pipewire
		  
		  # Video
		  libde265
		  libdv
		  libmpeg2
		  schroedinger
		  libtheora
		  libvpx
		  x264
		  x265
		  xvidcore
		  gstreamer
		  ffmpeg
		  gst-libav
		  gst-plugins-good
		  gst-plugins-ugly
		  gst-plugins-bad
		  
		  # Print
		  cups
		  cups-pdf
		  cups-filters
		  ghostscript
		  gsfonts
		  foomatic-db-engine
		  foomatic-db
		  gutenprint
		  
		  # Display Manager
		  sddm
		  archcraft-sddm-theme
		  		  
		  # Terminal
		  alacritty
		  xfce4-terminal
		  
		  # Apps
		  firefox
		  geany
		  geany-plugins
		  thunar
		  thunar-archive-plugin
		  thunar-media-tags-plugin
		  thunar-volman
		  viewnior
		  atril
		  
		  # Media
		  mpc
		  mpd
		  ncmpcpp
		  mplayer
		  
		  # Utilities
		  acpi
		  bc
		  dialog
		  dunst
		  fake-hwclock
		  galculator
		  gparted
		  gtk-engine-murrine
		  gnome-keyring
		  inetutils
		  inotify-tools
		  jq
		  lsb-release
		  meld
		  nitrogen
		  pastel
		  picom
		  plank
		  polkit
		  polybar
		  python-pywal
		  rofi
		  maim
		  slop
		  sudo
		  tint2
		  udisks2
		  wmctrl
		  wmname
		  xclip
		  xcolor
		  xdotool
		  xfce4-power-manager
		  xfce4-settings
		  xmlstarlet
		  xsettingsd
		  yad
		  zsh
		  
		  # QT Style
		  kvantum
		  qt5ct

		  # WMs
		  archcraft-openbox
		  archcraft-bspwm
		  archcraft-i3wm
		  
		  # Archcraft Specific
		  archcraft-hooks
		  archcraft-mirrorlist

		  # Archcraft Packages
		  archcraft-about
		  archcraft-artworks
		  archcraft-wallpapers
		  archcraft-config-geany
		  archcraft-config-music
		  archcraft-config-qt
		  archcraft-cursors
		  archcraft-dunst-icons
		  archcraft-fonts
		  archcraft-funscripts
		  archcraft-themes
		  archcraft-help
		  archcraft-hooks-extra
		  archcraft-hooks-zsh
		  archcraft-icons
		  archcraft-music
		  archcraft-neofetch
		  archcraft-omz
		  archcraft-randr
		  archcraft-ranger
		  archcraft-vim
		  		  
		  # Fonts
		  noto-fonts
		  noto-fonts-emoji
		  noto-fonts-cjk
		  terminus-font
		  
		  # Multimedia
		  ffmpeg
		  ffmpegthumbnailer
		  tumbler
		  
		  # Images
		  jasper
		  libwebp
		  libavif
		  libheif
		  
		  # Files
		  gvfs
		  gvfs-mtp
		  gvfs-afc
		  gvfs-gphoto2
		  gvfs-smb
		  gvfs-google
		  highlight
		  trash-cli
		  ueberzug
		  xdg-user-dirs
		  xdg-user-dirs-gtk
		  
		  # Archives
		  bzip2
		  gzip
		  lrzip
		  lz4
		  lzip
		  lzop
		  xz
		  zstd
		  p7zip
		  zip
		  unzip
		  unrar
		  unarchiver
		  xarchiver
		  		  
		  # Package Tools
		  base-devel
		  bison
		  fakeroot
		  flex
		  make
		  automake
		  autoconf
		  pkgconf
		  patch
		  gcc
		  
		  # CLI Tools
		  htop
		  nethogs
		  ncdu
		  powertop
		  ranger
		  vim
		    
		  # AUR Packages
		  betterlockscreen
		  downgrade
		  gtk3-nocsd-git
		  i3lock-color
		  ksuperkey
		  light
		  networkmanager-dmenu-git
		  obmenu-generator
		  perl-linux-desktopfiles
		  xfce-polkit
		  yay
		  
		  # My Packages
		  sl
)
