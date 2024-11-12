#!/usr/bin/env bash

# My arch setup script

# Some colors for output
RED="\e[1;31m"
GRN="\e[1;32m"
CYAN="\e[1;36m"
RST="\e[0m"

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

disk_partitioning(){
    echo "Which device would you like to partition?:"
    read -rp "" device
    echo $device
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

install_xorg_packages() {
    PKGS=(
            'xorg-server'
            'xorg-apps'
            'xorg-xinit'
            'xf86-video-intel'
            'mesa'
            'xf86-input-libinput'
    )
    install_packages "XORG" PKGS[@]
}

install_fonts() {
    PKGS=(
            'ttf-hack'
            'ttf-hack-nerd'
            'ttf-nerd-fonts-symbols'
            'ttf-nerd-fonts-symbols-mono'
            'ttf-font-awesome'
            'noto-fonts-emoji'
    )
    install_packages "fonts" PKGS[@]
}

install_utils_and_applications() {
    PKGS=(
            'git'
            'vim'
            'gvfs'
            'pacman-contrib'
            'polkit-gnome'
            'tlp'
            'tlp-rdw'
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
            'sxhkd'
            'ffmpeg'
            'mpv'
            'sxiv'
            'maim'
            'feh'
            'qalculate-gtk'
            'zathura'
            'zathura-pdf-poppler'
            'bitwarden'
            'nemo'
            'chromium'
            'gimp'
            'less'
    )
    install_packages "utilities and applications" PKGS[@]
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

install_configs() {
    msg "Installing configs"

    git clone https://github.com/sagevik/config.git ~/config

    for file in ~/config/.*; do
        [ -f "$file" ] && cp -f "$file" ~/
    done

    cp -rf ~/config/.config/* ~/.config/

    rm -rf ~/config

    msg "Done"
}

setup_config_bare_repo() {
    msg "Installing configs"
    cd ~/
    # clone config repo and set up as bare repo
    git clone --bare https://github.com/sagevik/config.git $HOME/config
    /usr/bin/git --git-dir=$HOME/config/ --work-tree=$HOME reset --hard
    /usr/bin/git --git-dir=$HOME/config/ --work-tree=$HOME config --local status.showUntrackedFiles no
    msg "Done"
}

install_scripts() {
    msg "Installing scripts"
    git clone https://github.com/sagevik/scripts.git ~/scripts
    sudo ~/scripts/./install.sh
}

install_touchpad_tap() {
    msg "Configuring tap to click"
    sudo ~/archomatic/./install_touchpad_conf.sh
}

# AUR stuff

install_yay() {
    if ! command -v yay &>/dev/null; then
        msg "Installing yay aur helper"
        git clone https://aur.archlinux.org/yay.git ~/.config/yay
        cd ~/.config/yay && makepkg -si
    else
        msg "yay already installed"
    fi
}

install_audio_mixer() {
    msg "Installing pavucontrol"
    yay -S pavucontrol-gtk3 --noconfirm
}

install_jottacloud_cli() {
    msg "Installing Jottacloud-cli"
    yay -S jotta-cli --noconfirm
    run_jottad
    loginctl enable-linger $USER
}

install_brave_browser() {
    msg "Installing Brave browser"
    yay -S brave-bin --noconfirm
}

install_joplin() {
    msg "Installing Joplin Desktop"
    yay -S joplin-desktop --noconfirm
}

# -------------------------

main_install() {
    msg "Starting installation and configuration."
    sleep 2

    # if is root then exit
    is_root

    # Ensure up-to-date system
    sudo pacman -Syu --noconfirm

    install_xorg_packages
    install_utils_and_applications
    install_suckless_tools
    install_configs
    install_scripts
    install_touchpad_tap

    # AUR stuff
    #install_yay
    #install_audio_mixer
    #install_jottacloud_cli
    #install_brave_browser
    #install_joplin

    install_fonts

    #setup_config_bare_repo
}


main_install

msg "Done installing, you can now reboot"
sleep 2
exit
