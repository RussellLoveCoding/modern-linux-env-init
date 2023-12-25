#!/usr/bin/env bash
# 主菜单
#set -x
set -e
source common.sh
setupShell() {

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

uninstallShell() {
    echoContent green " ---> uninstalling zsh and ohmyzsh"
    uninstall_oh_my_zsh
}

# ssh 端口号修改
# need to be root
sshConfig() {
    $installType sshpass 1>/dev/null
    $installType net-tools  1>/dev/null
    if netstat -tunlp | grep 12022 >/dev/null; then
        echoContent red " ---> port 12022 is already in use, please choose another one"
        return
    fi

    if [ ! -f /etc/ssh/sshd_config.bak ]; then
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    fi
   echoContent red 'configuring ssh port, please make sure you have open the port in firewall, will remove 22 port, keep other ports, add new port if no other port left'
    # remove 22 port
    sudo sed -rin '/^#?Port\s*22$/d' /etc/ssh/sshd_config
    # add new port
    sudo sed -i '$a\Port 12022' /etc/ssh/sshd_config

    sudo sed -rin 's~^#?\s*PasswordAuthentication yes~PasswordAuthentication no~g;' /etc/ssh/sshd_config
    sudo sed -rin 's~^#?\s*PubkeyAuthentication yes~PubkeyAuthentication yes~g;' /etc/ssh/sshd_config
    sudo systemctl restart sshd
}

setupSensitiveEnvironment() {
    echoContent green " ---> setting up sensitive environment"
    echoContent green " ---> please modfiy template files under directory $HOME/.secrets"
    cp -r ${modernEnvHomeDir}/secrets $HOME/.secrets
    chmod 600 $HOME/.secrets/*
    chmod 700 $HOME/.secrets
}

setupToolsByDPKG() {
    echoContent skyBlue "\n Progress $1/${totalProgress} : installing basic tools"

    # echoContent skyBlue "\n进度  $1/${totalProgress} : 安装工具"
    echoContent skyBlue "installing necassary tools"

    # fix some ubuntu os problem
    if [[ "${release}" == "ubuntu" ]]; then
        sudo dpkg --configure -a
    fi

    if [[ -n $(pgrep -f "apt") ]]; then
        sudo pgrep -f apt | xargs kill -9
    fi

    # packages using general install method
    echoContent green " ---> installing basic tools"
    ${upgrade} >>${execLogFile}

    for pkg in $pkgsKeys; do
        pkgName="$pkg"
        commandName=${pkgsDict[$pkgName]}
        command_exists $commandName || ${installType} ${pkgName} 1>/dev/null
        command_exists $commandName || {
            echoContent red " ---> ${pkgName} installation failed, see ${errLogFile} for details"
        }
    done

    # packages using special install method
    if ! find /usr/bin /usr/sbin | grep -q -w cron; then
        if [[ "${release}" == "ubuntu" ]] || [[ "${release}" == "debian" ]]; then
            ${installType} cron 1>/dev/null
        else
            ${installType} crontabs 1>/dev/null
        fi
    fi
    command_exists crontab || echoContent red " ---> ${pkg} installation failed, see ${errLogFile} for details"

}

installOtherBasicTools() {
    # 在 terminal 下从远程主机复制文本到本地剪贴板
    sudo \cp ${modernEnvPath}/bin-scripts/osc52 /usr/local/bin/

}

setupNeovim() {
    echoContent skyBlue "\n Progress $1/${totalProgress} : installing basic tools"
    command_exists nvim && {
        echoContent green " ---> nvim have been installed, continue to configure"
    }

    if ! command_exists nvim; then
        pushd /tmp
        sudo apt update 1>/dev/null
        echoContent green " ---> installing dependencies"
        {
            $installType git curl autoconf make tar gcc 1>/dev/null
            if [ $release == "ubuntu" ]; then
                $installType pkg-config 1>/dev/null
            elif [ $release == "centos" ]; then
                $installType pkgconfig 1>/dev/null
            fi
            if ! command_exists node; then
                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash >>${errLogFile} 1>/dev/null
                source $shellProfile
                nvm install node
                nvm use node
	    fi
	    if ! command_exists ctags; then
	        if [ -d ctags ]; then
	            rm -rf ctags
	        fi
                git clone https://github.com/universal-ctags/ctags.git 1>/dev/null 2>&1
                cd ctags
                ./autogen.sh 1>/dev/null 2>&1
                ./configure 1>/dev/null  2>&1
                make -j   1>/dev/null 2>&1
                sudo make install  1>/dev/null 2>&1
                cd .. 
                sudo \rm -rf ctags
	    fi
        }

        if [ "$arch" == "x86_64" ]; then
            archVariant=64
        fi
	echoContent green " ----> downloading neovim tarball"
        curl -sSOL https://github.com/neovim/neovim/releases/download/stable/nvim-linux${archVariant}.tar.gz
        sudo tar -xzf nvim-linux${archVariant}.tar.gz -C /usr/local/
        sudo mv /usr/local/nvim-linux$archVariant /usr/local/nvim
        sudo ln -s /usr/local/nvim/bin/nvim /usr/local/bin/nvim
        rm nvim-linux${archVariant}.tar.gz
        popd
    fi

    command_exists nvim || {
        echoContent red " ---> nvim installtion failed, see ${errLogFile} for details"
        return
    }

    echoContent "--> configuring nvim"
    if [ ! -d ~/.config/nvim ]; then
        [ ! -d ~/.config ] && mkdir -p ~/.config
        \cp -rf ${modernEnvHomeDir}/config/nvim ~/.config/nvim
    fi

    # install vim-plug
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    nvim -c 'PlugInstall' -c 'qa!'
}

uninstallNeovim() {
    rm -rf ~/.vim
    rm -rf ~/.config/nvim
    sudo rm `which nvim`
}

setupTmux() {
    echoContent skyBlue "\n Progress $1/${totalProgress} : installing basic tools"
    # install tmux
    # sudo yum install -y libevent-devel.x86_64
    # cd $TMPDIR
    # curl -L "https://github.com/tmux/tmux/releases/download/3.2a/tmux-3.2a.tar.gz" -o tmux-3.2a.tar.gz
    # tar xzf tmux-3.2a.tar.gz
    # cd tmux-3.2a
    # ./configure && make -j && sudo make install

    # install tmux
    echoContent green " ---> installing tmux"
    if command_exists tmux; then
        echoContent green " ---> tmux have been installed, continue to configure tmux"
    else
        $installType tmux 1>/dev/null
    fi
    if ! command_exists tmux; then
        echoContent red " ---> tmux installation failed, see ${errLogFile} for details"
        return
    fi

    echoContent green " ---> configuring tmux"
    [ ! -d $HOME/.tmux/plugins/tpm ] && {
        git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm 1>/dev/null
    }
    [ -f ~/.tmux.conf ] && mv ~/.tmux.conf ~/.tmux.conf.bak
    \cp ${modernEnvHomeDir}/tmux.conf ~/.tmux.conf
    # tmux source ~/.tmux.conf
    # cp /home/cmc/dev-env-setting/mux-airline-gruvbox-dark.conf ~/.tmux/

    echoContent green "please enter tmux seesion and install tmux plugin with key stroke prefix-I"
    echoContent green "common key binding: prefix+I for install plugin; prefix+U for udpate "

}

setupDisk() {
    $upgrade 1>/dev/null 2>&1
    $installType nfs-common  1>/dev/null 2>&1
    sudo echo "192.168.100.3:/volume1/root /home/hin/nas nfs defaults 0 0" >> /etc/fstab
    sudo mount -a
}

uninstallTmux() {
    $removeType tmux
}

installEnhancedTools() {
    echoContent skyBlue "\n Progress $1/${totalProgress} : installing basic tools"
    if [ ! -d ~/.fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf 1>/dev/null
        ~/.fzf/install
    else
        echoContent green " ---> fzf directory already exists"
    fi
}

uninstallEnhancedTools() {
    ~/.fzf/uninstall
    rm -rf ~/.fzf
}

setupAll() {
    sshConfig
    setupToolsByDPKG
    setupTmux
    setupNeovim
    installEnhancedTools
    installOtherBasicTools
    setupSensitiveEnvironment
    setupShell
}
