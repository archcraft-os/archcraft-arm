#!/usr/bin/env bash

## Copyright (C) 2020-2024 Aditya Shakya <adi1090x@gmail.com>
##
## Archcraft ARM Installation
##
## It is advised that you run this script on a fresh installation of Arch Linux ARM.

## Colors and Text ------------------------------------

## ANSI Colors
RED="$(printf '\033[31m')"      GREEN="$(printf '\033[32m')"
ORANGE="$(printf '\033[33m')"   BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"
WHITE="$(printf '\033[37m')"    BLACK="$(printf '\033[30m')"

## Reset Terminal Colors
reset_color() {
	tput sgr0   # reset attributes
	tput op     # reset color
    return
}

## Messages
show_msg() {
	if [[ "$1" == '-r' ]]; then
		{ echo -e ${RED}"$2"; reset_color; }
	elif [[ "$1" == '-g' ]]; then
		{ echo -e ${GREEN}"$2"; reset_color; }
	elif [[ "$1" == '-o' ]]; then
		{ echo -e ${ORANGE}"$2"; reset_color; }
	elif [[ "$1" == '-b' ]]; then
		{ echo -e ${BLUE}"$2"; reset_color; }
	elif [[ "$1" == '-m' ]]; then
		{ echo -e ${MAGENTA}"$2"; reset_color; }
	elif [[ "$1" == '-c' ]]; then
		{ echo -e ${CYAN}"$2"; reset_color; }
	fi
}

## Global Variables -----------------------------------

_dir="`pwd`"
_rootfs="$_dir/airootfs"
_copy_cmd='cp --preserve=mode --force --recursive'

## General Functions ----------------------------------

## Script termination
exit_on_signal_SIGINT() {
	show_msg -r "\n[!] Script interrupted.\n"
	exit 1
}

exit_on_signal_SIGTERM() {
	show_msg -r "\n[!] Script terminated.\n"
	exit 1
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Check command status
check_error_status() {
	if [[ "$?" != '0' ]]; then
		{ show_msg -r "\n[!] Error: Failed to $1 '$2' ${3}, Exiting... \n"; exit 1; }
	fi
}

## Check for root user
check_root_user() {
	if [[ `whoami` != 'root' ]]; then
		{ show_msg -r "\n[!] Please run the script as 'root' user, Exiting...\n"; exit 1; }
	fi
}

## Check internet connection
check_internet() {
	show_msg -b "\n[*] Checking for internet connection..."
	if ping -c 3 www.google.com &>/dev/null; then
		show_msg -g "[+] Connected to internet."
	else
		show_msg -r "[-] No internet connectivity.\n[!] Connect to internet and run the script again.\n"
		exit 1;
	fi
}

## Requirements ---------------------------------------
requirements() {
	# Check for architecture
	show_msg -b "\n[*] Checking for supported architecture ..."
	if [[ `uname -m` == 'aarch64' ]]; then
		show_msg -g "[+] Architecture '`uname -m`' is supported."
	elif [[ `uname -m` == "arm"* ]]; then
		show_msg -g "[+] Architecture '`uname -m`' is supported."
	else
		{ show_msg -r "\n[!] Architecture `uname -m` is not supported, Exiting...\n"; exit 1; }		
	fi

    # Check for available space
    space_root="`df -h | grep -w '/' | tr -s ' ' | cut -d' ' -f4 | tr -d "[:alpha:]"`"
    space_boot="`df -h | grep -w '/boot' | tr -s ' ' | cut -d' ' -f4 | tr -d "[:alpha:]"`"
	show_msg -b "\n[*] Checking for available space ..."
	if [[ "$space_root" < 10 ]]; then
		show_msg -r "[!] Warning: Minimum required space for 'root' partition is 10G. (Current Free Space : ${space_root}G)"
		warn_space=1
	fi
	if [[ "$space_boot" < 300 ]]; then
		show_msg -r "[!] Warning: Minimum required space for 'boot' partition is 300M. (Current Free Space : ${space_boot}M)"
		warn_space=1
	fi
	if [[ "$warn_space" == 1 ]]; then
		show_msg -r "[!] Warning: The Installation may fail due to limited space on the disk."	
	fi
	
    # Generate C.UTF-8 locale and set the language
	show_msg -b "\n[*] Generating C.UTF-8 locale and setting the language ..."
    sed -i "s/#C.UTF-8/C.UTF-8/" /etc/locale.gen
    locale-gen >/dev/null 2>&1
    export LANG=C.UTF-8
    
	show_msg -b "\n[*] Initialising the installation ..."
    sleep 5
}

## Banner ---------------------------------------------

banner() {
	clear
    cat <<- EOF
		${GREEN}░█▀█░█▀▄░█▀▀░█░█░█▀▀░█▀▄░█▀█░█▀▀░▀█▀
		${GREEN}░█▀█░█▀▄░█░░░█▀█░█░░░█▀▄░█▀█░█▀▀░░█░
		${GREEN}░▀░▀░▀░▀░▀▀▀░▀░▀░▀▀▀░▀░▀░▀░▀░▀░░░░▀░${WHITE}
		
		${CYAN}Archcraft ARM ${WHITE}: ${MAGENTA}Archcraftify your Arch Linux ARM (`uname -m`) installation
		${CYAN}Developed By  ${WHITE}: ${MAGENTA}Aditya Shakya (@adi1090x)
		
		${RED}Recommended   ${WHITE}: ${ORANGE}Install this on a fresh installation of Arch Linux ARM ${WHITE}
	EOF
}

## Perform Update ----------------------------

## Initialize the pacman keyring
initialize_keyring() {
	check_internet
	show_msg -b "\n[*] Initializing and populating the pacman keyring..."

	pacman-key --init
	check_error_status 'initialize' 'pacman' 'keyring'
	
	pacman-key --populate archlinuxarm
	check_error_status 'populate' 'archlinuxarm' 'keyring'
}

## Add archcraft-arm repository in pacman.conf
add_repository() {
	show_msg -b "\n[*] Adding 'archcraft-arm' repository in pacman config file..."
	sed -i -e 's|\[core\]|\[archcraft-arm\]'"\nSigLevel = Optional TrustAll\nServer = https://armpkgs.archcraft.io/\$arch\n\n"'\[core\]|g' /etc/pacman.conf
	check_error_status 'add' 'archcraft-arm' 'repository'
}

## Perform system upgrade
upgrade_system() {
	add_repository
	show_msg -b "\n[*] Performing system upgrade..."
	pacman -Syyu --noconfirm
	check_error_status 'perform' 'system' 'upgrade'
}

## Source the packages list
source_packages_file() {
	packages_file="$_dir/packages.sh"

	if [[ -f "$packages_file" ]]; then
		show_msg -b "\n[*] Sourcing packages file ($packages_file) ..."
		source "$packages_file"
		check_error_status 'source' 'packages' 'file'	
	else
		{ show_msg -r "\n[!] File '$packages_file' not found! Have you deleted it? Exiting...\n"; exit 1; }
	fi
}

## Install all packages at once
install_packages_at_once() {
	source_packages_file
	show_msg -b "\n[*] Installing required packages..."

	show_msg -o "[+] The following packages are going to be installed..."
	echo -e "${_packages[@]}\n"
	pacman -S --needed --noconfirm "${_packages[@]}"
	check_error_status 'install' 'some' 'packages'
}

## Install one package at a time
install_packages_one_by_one() {
	source_packages_file
	show_msg -b "\n[*] Installing required packages..."

	for _pkg in "${_packages[@]}"; do
		show_msg -o "\n[+] Installing package : $_pkg"
		pacman -S "$_pkg" --needed --noconfirm
		if [[ "$?" != '0' ]]; then
			show_msg -r "\n[!] Failed to install package: $_pkg"
			_failed_to_install+=("$_pkg")
		fi
	done
	
	# List failed packages
	if [[ -n "${_failed_to_install}" ]]; then
		echo
		if [[ ! -f "$_dir/failed_pkgs" ]]; then
			touch "$_dir/failed_pkgs"
		fi
		for _failed in "${_failed_to_install[@]}"; do
			show_msg -r "[!] Failed to install package : ${ORANGE}${_failed}"
			echo ${_failed} >> "$_dir/failed_pkgs"
		done
		{ show_msg -r "\n[!] Failed packages can be found in '$_dir/failed_pkgs' file.\nInstall these packages manually to continue, exiting...\n"; exit 1; }
	fi
}

## Manage Services ---------------------------
manage_services() {
	_serv_enable=(NetworkManager
				  wpa_supplicant
				  ModemManager
				  bluetooth
				  systemd-timesyncd
				  fake-hwclock
				  sddm)
	_serv_disable=(systemd-networkd)

	show_msg -b "\n[*] Enabling systemd services..."
	for _serv in "${_serv_enable[@]}"; do
		if ! systemctl is-enabled "${_serv}.service" &>/dev/null ; then
			show_msg -o "\n[+] Enabling '$_serv' service..."
			systemctl enable "${_serv}.service"
			check_error_status 'enable' "$_serv" 'service'	
		fi
	done

	show_msg -b "\n[*] Disabling systemd services..."	
	for _serv in "${_serv_disable[@]}"; do
		if systemctl is-enabled "${_serv}.service" &>/dev/null ; then
			show_msg -o "\n[+] Disabling '$_serv' service..."
			systemctl disable "${_serv}.service"
			check_error_status 'disable' "$_serv" 'service'	
		fi
	done

	show_msg -b "\n[*] Setting graphical as default target..."
	systemctl set-default graphical.target
	check_error_status 'set' 'default' 'target'	
} 

## System wide configs -----------------------

## Install system wide config files
install_sys_config_files() {
	show_msg -b "\n[*] Installing system-wide config files..."
	
	_sys_cfgs=(plymouth polkit-1 sddm.conf.d sudoers.d udev X11 environment hostname locale.conf sddm.conf vconsole.conf)
	for _scfg in "${_sys_cfgs[@]}"; do
		show_msg -o "\n[+] Installing ${_scfg} files..."
		${_copy_cmd} --verbose "$_rootfs"/etc/${_scfg} /etc
		check_error_status 'install' "$_scfg" 'files in /etc directory'
	done
}

## Install skeleton
install_skeleton_files() {
	_skel='/etc/skel'

	show_msg -b "\n[*] Installing skeleton files..."

	_skel_files=(`ls --almost-all --group-directories-first ${_rootfs}/etc/skel/`)
	for _skfile in "${_skel_files[@]}"; do
		show_msg -o "[+] Installing ${_skfile} files..."
		${_copy_cmd} "$_rootfs"/etc/skel/${_skfile} "$_skel"
		check_error_status 'install' "$_skfile" "files in $_skel directory"	
	done
}

## Install misc files
install_misc_files() {
	show_msg -b "\n[*] Installing misc files..."
	
	${_copy_cmd} "$_rootfs"/usr/local/bin/xflock4    /usr/local/bin/
	${_copy_cmd} "$_rootfs"/var/lib/sddm/state.conf  /var/lib/sddm/
}

## Post Installation -------------------------

## Perform post installation operations
perform_post_installation() {
	custom_file="$_dir/customize.sh"

	## Source customisation file
	if [[ -f "$custom_file" ]]; then
		show_msg -b "\n[*] Sourcing customisation file ($custom_file) ..."
		source "$custom_file"
		check_error_status 'source' 'customize' 'file'	
	else
		{ show_msg -r "\n[!] File '$custom_file' not found! Have you deleted it? Exiting...\n"; exit 1; }
	fi

	## Set Hostname
	show_msg -o "\n[*] Setting Hostname as '$your_hostname' ..."
	echo "$your_hostname" > /etc/hostname
	
	## Set System Locale
	show_msg -o "\n[*] Setting '$your_locale' as System Locale ..."
	echo "LANG=\"${your_locale}\"" > /etc/locale.conf
	sed -i -e "s/#${your_locale}/${your_locale}/" /etc/locale.gen
	locale-gen &>/dev/null

	## Set Timezone and Clock
	show_msg -o "\n[*] Setting Timezone to '$your_timezone' ..."
    ln -sf /usr/share/zoneinfo/${your_timezone} /etc/localtime

	show_msg -o "\n[*] Setting Clock to '$your_clock' ..."
	hwclock --systohc --${your_clock}

	## Add New User
	show_msg -o "\n[*] Creating user : '$your_username' ..."
	useradd ${your_username} -p `openssl passwd $your_password` -m -g users -G ${your_groups} -s ${your_shell}

	# Set up basic configuration files and ownership for new account
	${_copy_cmd} /etc/skel/. /home/${your_username}
	chown -R ${your_username}:users /home/${your_username}

	# Copy basic configuration files in /root
	${_copy_cmd} /etc/skel/. /root

	# Change sudoers file to require passwords for sudo commands
	echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/01_wheel
}

## Misc Operations ---------------------------

## Perform misc operations
perform_misc_operations() {
	show_msg -b "\n[*] Performing various operations..."

	if [[ `uname -m` == "arm"* ]]; then
		show_msg -o "[+] Adding 'plymouth' hook in mkinitcpio config file..."
		sed -i -e 's/udev/udev plymouth/g' /etc/mkinitcpio.conf
	fi

	show_msg -o "[+] Regenerating initrd image..."
	mkinitcpio -P

	if [[ -e "/boot/cmdline.txt" ]]; then
		show_msg -o "[+] Adding kernel parameters in boot file..."
		sed -i -e '$ s/$/ quiet splash loglevel=3 udev.log_level=3 vt.global_cursor_default=0/' /boot/cmdline.txt
	fi

	show_msg -o "[+] Updating pacman.conf file..."
	sed -i -e 's|Server = https://armpkgs.archcraft.io/\$arch|Include = /etc/pacman.d/archcraft-mirrorlist|g' /etc/pacman.conf

	show_msg -o "[+] Setting zsh as default shell for new users..."
	sed -i -e 's#SHELL=.*#SHELL=/bin/zsh#g' /etc/default/useradd

	show_msg -o "[+] Fixing default cursor theme..."
	rm -rf /usr/share/icons/default

	show_msg -o "[+] Updating font cache..."
	fc-cache

	show_msg -o "[+] Making scripts executable..."
	chmod 755 /usr/local/bin/*

	show_msg -o "[+] Updating user ${your_username}'s home directories..."
	runuser -l ${your_username} -c 'xdg-user-dirs-update'
	runuser -l ${your_username} -c 'xdg-user-dirs-gtk-update'
}

## Finalization --------------------------------------

finalization() {
	show_msg -b "\n[*] Performing cleanup..."

	# Remove all downloaded packages
	show_msg -o "[-] Removing packages from cache directory..."
	rm -rf /var/cache/pacman/pkg/*

	# Delete current user
	read -p ${CYAN}"[?] Do you want to delete the default user 'alarm' (y/n) : "${WHITE}
	if [[ "$REPLY" == 'y' || "$REPLY" == 'Y' ]]; then
		show_msg -o "[-] Deleting default user ..."
		userdel -f -r alarm
	else
		${_copy_cmd} /etc/skel/. /home/alarm
		chown -R alarm:alarm /home/alarm
	fi

	# Remove un-needed files
	show_msg -o "[-] Removing un-needed files from /home directory..."
	if [[ -d '/home/root' ]]; then
		rm -rf /home/root
	fi

	# Completed
	show_msg -g "\n[*] Installation Completed, You may now reboot your computer.\n"
}

## Main --------------------------------------
check_root_user
requirements
banner
initialize_keyring
upgrade_system
#install_packages_at_once
install_packages_one_by_one
manage_services
install_sys_config_files
install_skeleton_files
install_misc_files
perform_post_installation
perform_misc_operations
finalization
