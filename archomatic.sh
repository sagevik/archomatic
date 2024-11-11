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

    edge=$(echo "$msg" | sed 's/./-/g')
    #echo "$edge"
    echo -e "$CYAN$edge"
    echo -e "$color$msg"
    echo -e "$CYAN$edge$RST"
    #echo "$edge"
}

disk_partitioning(){
    echo "Which device would you like to partition?:"
    read -rp "" device
    echo $device
}

install_xorg_packages() {
    msg "Installing XORG packages"

    PKGS=(
            'xorg-server'
            'xorg-apps'
            'xorg-xinit'
            'xf86-video-intel'
            'mesa'
            'xf86-input-libinput'
    )

    for PKG in "${PKGS[@]}"; do
        echo "Installing: ${PKG}"
        sudo pacman -S "$PKG" --noconfirm --needed
    done

    msg "Done!"
}

install_fonts() {
    msg "Installing fonts"

    PKGS=(
            'ttf-hack'
            'ttf-hack-nerd'
            'ttf-nerd-fonts-symbols'
            'ttf-nerd-fonts-symbols-mono'
            'ttf-font-awesome'
            'noto-fonts-emoji'
    )

    for PKG in "${PKGS[@]}"; do
        echo "Installing: ${PKG}"
        sudo pacman -S "$PKG" --noconfirm --needed
    done

    msg "Done!"
}

install_utils_and_applications() {
    msg "Installing utilities and applications"

    PKGS=(
            'git'
            'gvfs'
            'pacman-contrib'
            'polkit-gnome'
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
    )

    for PKG in "${PKGS[@]}"; do
        echo "Installing: ${PKG}"
        sudo pacman -S "$PKG" --noconfirm --needed
    done

    msg "Done!"
}

install_tlp() {
    msg "Installing TLP"

    PKGS=(
            'tlp'
            'tlp-rdw'
    )

    for PKG in "${PKGS[@]}"; do
        echo "Installing: ${PKG}"
        sudo pacman -Sy "$PKG" --noconfirm --needed
    done

    msg "Done!"
}

install_dwm() {
    msg "Installing dwm"
    mkdir -p ~/.config/suckless
    cd ~/.config/suckless
    git clone https://github.com/sagevik/dwm.git
    cd ~/.config/suckless/dwm
    sudo make clean install
}

install_dmenu() {
    msg "Installing dmenu"
    mkdir -p ~/.config/suckless
    cd ~/.config/suckless
    git clone https://github.com/sagevik/dmenu.git
    cd ~/.config/suckless/dmenu
    sudo make clean install
}

install_slstatus() {
    msg "Installing slstatus"
    mkdir -p ~/.config/suckless
    cd ~/.config/suckless
    git clone https://github.com/sagevik/slstatus.git
    cd ~/.config/suckless/slstatus
    sudo make clean install
}

install_st() {
    msg "Installing st"
    mkdir -p ~/.config/suckless
    cd ~/.config/suckless
    git clone https://github.com/sagevik/st.git
    cd ~/.config/suckless/st
    sudo make clean install
}

install_slock() {
    msg "Installing slock"
    mkdir -p ~/.config/suckless
    cd ~/.config/suckless
    git clone https://github.com/sagevik/slock.git
    cd ~/.config/suckless/slock
    sudo make clean install
}

install_configs() {
    msg "Installing configs"
    cd ~/
    git clone https://github.com/sagevik/config.git
    cd ~/config
    cp .bashrc ~/.bashrc
    cp .bash_profile ~/.bash_profile
    cp .inputrc ~/.inputrc
    cp .xinitrc ~/.xinitrc
    cd ~/config/.config
    cp -r * ~/.config/
    msg "Done"
}

install_scripts() {
    msg "Installing scripts"
    cd ~/
    git clone https://github.com/sagevik/scripts.git
    cd ~/scripts
    sudo ./install.sh
}

install_touchpad_tap() {
    msg "Configuring tap to click"
sudo echo 'Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
        Option "Tapping" "on"
        Option "DisableWhileTyping" "on"
EndSection' >> /etc/X11/xorg.conf.d/50-libinput.conf
}

main_install() {
    msg "Starting installation and configuration."
    sleep 2

    # if is root then exit
    is_root

    install_xorg_packages

    install_tlp

    install_fonts

    install_utils_and_applications

    msg "Installing suckless tools"
    install_dwm
    install_dmenu
    install_slstatus
    install_st
    install_slock
    msg "Done"

    install_configs

    install_scripts

    install_touchpad_tap
}


main_install

msg "Done installing, you can now reboot"
sleep 2
exit
