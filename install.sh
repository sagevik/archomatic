#!/usr/bin/env bash

# My arch setup script

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Some colors for output
RED="\e[1;31m"
GRN="\e[1;32m"
CYAN="\e[1;36m"
RST="\e[0m"

# Introductory disclaimer
msg_intro() {
    echo -e "${CYAN}--------------------------------------------${RST}"
    echo -e "${GRN}   Arch Linux Setup Script by sagevik${RST}"
    echo -e "${CYAN}--------------------------------------------${RST}"
    echo -e "${RED}This script is provided as-is, with no guarantees."
    echo -e "Use of this script is at your own risk, and the author"
    echo -e "assumes no responsibility for any issues that may arise.${RST}"
    echo -e "${CYAN}--------------------------------------------${RST}"
    echo
}

# Confirmation prompt
confirm_continue() {
    read -rp "Do you want to continue with the installation? (yes/no): " response
    case "$response" in
        [Yy][Ee][Ss]) echo -e "${GRN}Continuing with the installation...${RST}" ;;
        *) echo -e "${RED}Installation aborted by user.${RST}" ; exit ;;
    esac
}


is_root() {
    [ "$EUID" = 0 ] && msg "Please run script as user NOT as root" RED && exit
}

msg() {
    msg=" $1 "
    color_var="${2:-GRN}"
    color=$(eval echo "\$$color_var")

    border=$(echo "$msg" | sed 's/./-/g')
    echo -e "$CYAN$border"
    echo -e "$color$msg"
    echo -e "$CYAN$border$RST"
}

install_packages() {
     msg "Installing $1 packages"
     local pkgs=("${!2}")
     for pkg in "${pkgs[@]}"; do
         echo "Installing: ${pkg}"
         sudo pacman -S "$pkg" --noconfirm --needed
     done
     msg "Done installing $1 packages"
}


install_timeshift() {
    msg "Installing Timeshift"

    # Prompt for confirmation
    read -rp "Do you want to install Timeshift and create an initial snapshot? [Y/n] " response

    # Check response (defaults to 'Yes')
    case "$response" in
        [nN][oO]|[nN])
            msg "Skipping Timeshift installation and snapshot creation"
            ;;
        *)
            # Install Timeshift
            sudo pacman -S timeshift --noconfirm --needed

            # Create Timeshift snapshot
            sudo timeshift --create

            msg "Timeshift installation and initial snapshot completed"
            ;;
    esac
}

install_xorg_packages() {
    local pkgs=(
            'xorg-server'
            'xorg-apps'
            'xorg-xinit'
            'xf86-video-intel'
            'mesa'
            'xf86-input-libinput'
    )
    install_packages "XORG" pkgs[@]
}

install_fonts() {
    local pkgs=(
            'ttf-hack'
            'ttf-hack-nerd'
            'ttf-nerd-fonts-symbols'
            'ttf-nerd-fonts-symbols-mono'
            'ttf-font-awesome'
            'noto-fonts-emoji'
    )
    install_packages "fonts" pkgs[@]
}

install_utils_and_applications() {
    local pkgs=(
            'base-devel'
            'git'
            'vim'
            'gvfs'
            'pacman-contrib'
            'polkit-gnome'
            'tlp'
            'tlp-rdw'
            'curl'
            'bash-completion'
            'bluez'
            'bluez-utils'
            'blueman'
            'networkmanager'
            'network-manager-applet'
            'brightnessctl'
            'arandr'
            'lxappearance'
            'picom'
            'dunst'
            'screenkeys'
            'ffmpeg'
            'mpv'
	    'neovim'
            'sxiv'
            'maim'
            'xwallpaper'
            'qalculate-gtk'
            'zathura'
            'zathura-pdf-poppler'
            'bitwarden'
            'nemo'
            'chromium'
            'gimp'
            'less'
            'tree'
            'fzf'
            'unzip'
            'stow'
            'supercollider'
            'haskell-tidal'
            'audacity'
	    'zoxide'
    )
    install_packages "utilities and applications" pkgs[@]
}

install_suckless_tools() {
    msg "Installing Suckless tools"
    mkdir -p ~/.config/suckless

    REPOS=(
        "dwm"
        "dmenu"
        "slstatus"
        "st"
        "slock"
    )

    for repo in "${REPOS[@]}"; do
        cd ~/.config/suckless
        if [ ! -d "$repo" ]; then
            git clone "https://github.com/sagevik/$repo.git"
        else
            msg "$repo already cloned, pulling latest changes."
            cd "$repo" && git pull
        fi
        cd ~/.config/suckless/"$repo" && sudo make clean install
    done
    msg "Done installing Suckless tools"
}

install_dotfiles() {
    msg "Installing dotfiles"

    git clone https://github.com/sagevik/dots.git ~/.dots
    cd ~/.dots
    # Check if stow is installed
    if ! command -v stow &> /dev/null; then
        sudo pacman -S stow --noconfirm --needed
    fi
    stow .

    # install bash.bashrc that points to ~/.config/bash/.bash_profile
    sudo cp ~/.dots/bash/bash.bashrc /etc

    msg "Done"
}

install_scripts() {
    msg "Installing scripts"
    git clone https://github.com/sagevik/scripts.git ~/scripts
    sudo ~/scripts/./install.sh
}

configure_touchpad_tap() {
    msg "Configuring tap to click"
    sudo "$SCRIPT_DIR/./configure_touchpad_conf.sh"
}

# Install AUR helper and applications
#--------------------------------------
install_yay() {
    if ! command -v yay &>/dev/null; then
        msg "Installing yay aur helper"
        git clone https://aur.archlinux.org/yay.git ~/.config/yay
        cd ~/.config/yay && makepkg -si
    else
        msg "yay is installed"
    fi
}

install_jottacloud_cli() {
    msg "Installing Jottacloud-cli"
    # Ensure yay is installed
    install_yay

    yay -S jotta-cli --noconfirm --needed
    run_jottad
    loginctl enable-linger $USER
}

install_yay_package() {
    # Ensure yay is installed
    install_yay

    local package="$1"
    echo "Installing: $package with yay"
    yay -S "$package" --noconfirm --nodiffmenu --nocleanmenu --removemake --needed
}

install_yay_packages() {
    local yay_packages=(
        "pavucontrol-gtk3"
        "brave-bin"
        "joplin-desktop"
        # Add more packages as needed
    )

    for package in "${yay_packages[@]}"; do
        install_yay_package "$package"
    done
}

install_aur_helper() {
    read -rp "Do you want to install Yay AUR helper? [Y/n] " response

    # Check response (defaults to 'Yes')
    case "$response" in
        [nN][oO]|[nN])
            msg "Skipping yay and AUR packages installation"
            ;;
        *)
            msg "Installing yay AUR helper"
            install_yay
            ;;
    esac
}

install_aur_packages() {
    read -rp "Do you want to install AUR packages? [Y/n] " response

    # Check response (defaults to 'Yes')
    case "$response" in
        [nN][oO]|[nN])
            msg "Skipping yay and AUR packages installation"
            ;;
        *)
            msg "Installing AUR packages"
            install_yay_packages
            ;;
    esac
}
#--------------------------------------

install_wallpapers() {
    msg "Installing wallpapers"

    cd ~/
    mkdir -p ~/pix

    git clone https://github.com/sagevik/wallpapers.git ~/pix/wallpapers

    if ! command -v ffmpeg &> /dev/null; then
        sudo pacman -S --needed --noconfirm ffmpeg
    fi
    mkdir -p ~/.local/share/background
    ffmpeg -loglevel quiet -y -i ~/pix/wallpapers/moss.jpg ~/.local/share/background/wp.png
}


main_install() {
    clear
    msg_intro
    confirm_continue

    clear
    msg "Starting installation and configuration."
    sleep 2

    # if is root then exit
    is_root

    # Ensure up-to-date system
    sudo pacman -Syu --noconfirm

    # Install Timeshift and create an initial snapshot
    install_timeshift

    # Packages installations
    install_xorg_packages
    install_utils_and_applications

    # Configs, fonts and utility scripts
    install_dotfiles
    install_fonts
    install_scripts

    # Install dwm, dmenu, st, slstatus and slock
    install_suckless_tools

    # Additional configuration and optional installs
    configure_touchpad_tap

    install_wallpapers

    # Install AUR helper
    install_aur_helper
    # Install Jotta backup
    install_jottacloud_cli
    # AUR packages
    install_aur_packages
}


main_install

msg "Done installing, you can now reboot"
sleep 2
exit
