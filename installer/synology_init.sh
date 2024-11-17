#!/bin/bash

# keep it simple

# https://imnks.com/335.html
install_opkg_package_manager() {

}

install_toolset() {

    # install git

    # install vim
}

init_docker() {

}

install_shell() {
    # install git via spk
    opkg install zsh


    echoContent green " ---> installing zsh and ohmyzsh"
    command_exists zsh && echoContent green " ---> zsh have been installed, continue to configure"
    command_exists zsh || {
        ${installType} zsh >/dev/null
    }
    command_exists zsh || {
        echoContent red " ---> zsh installation failed, see ${errLogFile} for details"
        return
    }
    echoContent green " ------------> configuring ohmyzsh"
    if [ -d ~/.oh-my-zsh ]; then
        echoContent green " ---> ohmyzsh directory already exists"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        chsh -s /usr/bin/zsh
    fi

    echoContent green " ------------> installing auto suggestion "
    if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 1>/dev/null
    else
        echoContent green " ---> zsh-autosuggestions directory already exists"
    fi

    echoContent green " ------------> installing auto suggestion "
    if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 1>/dev/null
    else
        echoContent green " ---> zsh-syntax-highlighting directory already exists"
    fi

    echoContent green " ------------> installing MRU, easy to access recently used files or directory"
    if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-z ]; then
        git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z 1>/dev/null
    else
        echoContent green " ---> zsh-z directory already exists"
    fi

    echoContent green " ------------> installing install powerlevel10k, a more comfotable theme, style for ohmyzsh"
    if [ ! -d $HOME/.oh-my-zsh/custom/themes/powerlevel10k ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k 1>/dev/null
        sed -rin 's~ZSH_THEME=.*~ZSH_THEME="powerlevel10k/powerlevel10k"~g;' $shellProfile
    else
        echoContent green " ---> powerlevel10k directory already exists, maybe you need to reset"
    fi

    sudo \cp ${modernEnvHomeDir}/global_aliases /etc/
    if [ -f ~/.zshrc ]; then
        mv ~/.zshrc ~/.zshrc-bak.$(date +'%y-%m-%d_%H:%M:%S')
    fi
    \cp ${modernEnvHomeDir}/zshrc $HOME/.zshrc
    echoContent green "you have to run 'p10k configure' manually, since this would cause other software installation failure."

}