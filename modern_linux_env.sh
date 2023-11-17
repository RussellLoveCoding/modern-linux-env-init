#!/usr/bin/env bash
# 检测区
# -------------------------------------------------------------
# 检查系统
export LANG=en_US.UTF-8
printHeader() {

    echo ""
    echo " ========================================================= "
    echo " \            Linux init.sh linux developing environment deploymnt script V 1.1             / "
    echo " ========================================================= "
    echo " # author：RussellLoveCoding
echo " # https://github.com/RussellLoveCoding                    "
    echo -e "\n"
}

# feature:
# 0. Idempotent. no side effect.
# 1. auto detect os system, cpu arch and choose the right version of software
# 2. auto detect shell profile
# 3. let you choose if encounter options.
# 4. you can remove installed packages using this script.

# print message $2 with specifid color $1

################# Helper Function  #################

echoContent() {
    case $1 in
    # 红色
    "red")
        # shellcheck disable=SC2154
        echo -e "\033[31m${printN}$2 \033[0m" >&3
        ;;
        # 天蓝色
    "skyBlue")
        echo -e "\033[1;36m${printN}$2 \033[0m"
        ;;
        # 绿色
    "green")
        echo -e "\033[32m${printN}$2 \033[0m"
        ;;
        # 白色
    "white")
        echo -e "\033[37m${printN}$2 \033[0m"
        ;;
    "magenta")
        echo -e "\033[31m${printN}$2 \033[0m"
        ;;
        # 黄色
    "yellow")
        echo -e "\033[33m${printN}$2 \033[0m"
        ;;
    esac
}

command_exists() {
    command -v "$@" 1>/dev/null 2>${errLogFile}
}

execute_with_timeout() {
    local cmd=$1
    local timeout_seconds=$2
    local error_message=$3

    timeout $timeout_seconds sh -c "$cmd"
    if [ $? -eq 124 ]; then
        echo "$error_message"
        exit 1
    fi
}

checkAndAddLine() {
    local file=$1
    local line=$2

    # 检查行是否存在
    if grep -qF "$line" $file; then
        # 如果存在并且被注释，取消注释

        # 使用printf '%s\n' "$line"来确保$line中的所有字符都被视为字面字符，而不是正则表达式的一部分S
        # -e 它允许你使用基本的正则表达式语法，而不是扩展的正则表达式语法。在基本的正则表达式语法中，你需要使用\来转义特殊字符
        sed -i -e "s~# *$(printf '%s\n' "$line")~$(printf '%s\n' "$line")~g" "$file"
    else
        # 该行不存在，追加它
        echo "$line" >>"$file"
    fi
    cat $file
}

# get os CPU vendor

# initialize global variable
# 在安装 install_zsh 后，需要再运行一次 init() 函数，以更新 shellProfile 变量
init() {

    # installation total progress
    totalProgress=1

    # path definition
    globalInstallDir='/usr/local'
    localInstallDir="$HOME/opt"
    errLogFile='/tmp/modern_linux_init_error.log'
    execLogFile='/tmp/modern_linux_init_exec.log'
    modernEnvPath="/tmp/modern-linux-env-init"
    modernEnvHomeDir="${modernEnvPath}/homedir"

    # command redefinition
    installType='apt -y install'
    removeType='apt -y remove'
    upgrade="apt -y update"

    wget='wget --no-check-certificate'
    curl='curl -OLk'
    optdir="$HOME/opt"
    usrlocal='/usr/local'
    
    # detect architecture and os type
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)

    # detect distribution
    distro=$(cat /etc/*-release | grep '^ID=' | cut -d'=' -f2)
    case "$distro" in
    "centos")
        release="centos"
        installType='yum -y install'
        removeType='yum -y remove'
        upgrade="yum update -y --skip-broken"
        ;;
    "debian")
        release="debian"
        installType='apt -y install'
        upgrade="apt update"
        removeType='apt -y autoremove'
        ;;
    "ubuntu")
        release="ubuntu"
        installType='apt -y install'
        upgrade="apt update"
        removeType='apt -y autoremove'
        ;;
    *)
        echo "不支持的系统"
        exit 1
        ;;
    esac

    # detect shell shell profile
    if [ -n "$($SHELL -c 'echo $ZSH_VERSION')" ]; then
        shellProfile="$HOME/.zshrc"
    elif [ -n "$($SHELL -c 'echo $BASH_VERSION')" ]; then
        shellProfile="$HOME/.bashrc"
    elif [ -n "$($SHELL -c 'echo $FISH_VERSION')" ]; then
        shell="fish"
        if [ -d "$XDG_CONFIG_HOME" ]; then
            shellProfile="$XDG_CONFIG_HOME/fish/config.fish"
        else
            shellProfile="$HOME/.config/fish/config.fish"
        fi
    fi

    # fetch necessary configuration file.
    [ -d $modernEnvPath ] || {
        echoContent green " --> fetching necessary configuration file from github"
        git clone https://github.com/RussellLoveCoding/modern-linux-env-init.git $modernEnvPath 1>/dev/null
    }
}

# ssh 端口号修改
# need to be root
sshConfig() {
    $installType sshpass
    sshNewPort=$1
    netstat -tunlp | grep $sshNewPort >/dev/null 2>&1 && {
        echoContent red " ---> port $sshNewPort is already in use, please choose another one"
        return
    }

    [ ! -f /etc/ssh/sshd_config.bak ] && sudo \cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    echo -e 'configuring ssh port, please make sure you have open the port in firewall, will remove 22 port, keep other ports, add new port if no other port left'
    # remove 22 port
    \sed -rin '/^#?Port\s*22$/d' /etc/ssh/sshd_config
    # add new port
    echo "Port $sshNewPort" >>/etc/ssh/sshd_config
    systemctl restart sshd
}

# install basic tools
setupBasicTools() {

    totalProgress=4

    pkgs="lsof man tmux htop autojump iotop ncdu jq telnet p7zip axel rename vim sqlite3 lrzsz \
    unzip git curl wget crontab lsof qrencode sudo htop man tldr tree ranger delta make tmux \
    yarn git iotop iftop atop httpie dstat rar colordiff autoconf gcc aria2"

    installBasicTools() {
        echoContent skyBlue "\n进度  $1/${totalProgress} : installing basic tools"

        # echoContent skyBlue "\n进度  $1/${totalProgress} : 安装工具"
        echoContent skyBlue "installing necassary tools"

        # fix some ubuntu os problem
        if [[ "${release}" == "ubuntu" ]]; then
            dpkg --configure -a
        fi

        if [[ -n $(pgrep -f "apt") ]]; then
            pgrep -f apt | xargs kill -9
        fi

        # packages using general install method
        echoContent green " ---> installing basic tools"
        ${upgrade} >${execLogFile} 2>&1

        ${installType} openssh-client openssh-server 1>/dev/null 2>${errLogFile}
        if ! command -v ssh >/dev/null || ! command -v sshd >/dev/null; then
            echoContent red " ---> ssh client or server installation failed, see ${errLogFile} for details"
        fi

        for pkg in $pkgs; do
            command_exists ${pkg} || ${installType} ${pkg} 1>/dev/null 2>${errLogFile}
            command_exists ${pkg} || {
                echoContent red " ---> ${pkg} installation failed, see ${errLogFile} for details"
            }
        done

        # packages using special install method
        if ! find /usr/bin /usr/sbin | grep -q -w cron; then
            if [[ "${release}" == "ubuntu" ]] || [[ "${release}" == "debian" ]]; then
                ${installType} cron 1>/dev/null 2>${errLogFile}
            else
                ${installType} crontabs 1>/dev/null 2>${errLogFile}
            fi
        fi
        command_exists crontab || echoContent red " ---> ${pkg} installation failed, see ${errLogFile} for details"

        ${installType} lsb-core 1>/dev/null 2>${errLogFile}
        command_exists lsb_release || echoContent red " ---> ${pkg} installation failed, see ${errLogFile} for details"

        command_exists ifconfig || ${installType} net-tools 1>/dev/null 2>${errLogFile}
        command_exists ifconfig || echoContent red " ---> net-tools installation failed, see ${errLogFile} for details"

        command_exists ping6 || ${installType} inetutils-ping 1>/dev/null 2>${errLogFile}
        command_exists ping6 || echoContent red " ---> inetutils-ping installation failed, see ${errLogFile} for details"

        command_exists ag || ${installType} silversearcher-ag 1>/dev/null 2>${errLogFile}
        command_exists ag || echoContent red " ---> silversearcher-ag installation failed, see ${errLogFile} for details"

        command_exists node || ${installType} nodejs 1>/dev/null 2>${errLogFile}
        command_exists node || echoContent red " ---> nodejs installation failed, see ${errLogFile} for details"
    }

    installNVim() {

        command_exists nvim && echoContent green " ---> nvim have been installed, nothing installed" && return

        pushd /tmp
        if [ "$arch" == "x86_64" ]; then
            archVariant=64
        fi
        curl -sSOL https://github.com/neovim/neovim/releases/download/stable/nvim-linux${archVariant}.tar.gz
        tar nvim-linux${archVariant}.tar.gz

        tar -xzf nvim-linux${archVariant}.tar.gz -C /usr/local/
        mv /usr/local/nvim-linux$archVariant /usr/local/nvim
        ln -s /usr/local/nvim/bin/nvim /usr/local/bin/nvim
        popd

        command_exists nvim || {
            echoContent red " ---> nvim installtion failed, see ${errLogFile} for details"
            return
        }

        echoContent "--> configuring nvim"
        if [ ! -d ~/.config/nvim ]; then
            \copy -rf ${modernEnvHomeDir}/.config/nvim ~/.config/nvim
        fi

        echoContent "--> nvim installed, later after you open nvim, plugin will be automatically installed"
    }

    installTmux() {
        # install tmux
        # sudo yum install -y libevent-devel.x86_64
        # cd $TMPDIR
        # curl -L "https://github.com/tmux/tmux/releases/download/3.2a/tmux-3.2a.tar.gz" -o tmux-3.2a.tar.gz
        # tar xzf tmux-3.2a.tar.gz
        # cd tmux-3.2a
        # ./configure && make -j 8 && sudo make install

        # install tmux
        echoContent green " ---> installing tmux"
        $installType tmux 1>/dev/null 2>${errLogFile}
        command_exists tmux || {
            echoContent red " ---> tmux installation failed, see ${errLogFile} for details"
            return
        }

        echoContent green " ---> configuring tmux"
        git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
        [ -f ~/.tmux.conf ] && mv ~/.tmux.conf ~/.tmux.conf.bak
        \cp ${modernEnvHomeDir}/.tmux.conf ~/.tmux.conf
        tmux source ~/.tmux.conf
        # cp /home/cmc/dev-env-setting/mux-airline-gruvbox-dark.conf ~/.tmux/

        echo "please enter tmux seesion and install tmux plugin with key stroke prefix-I"
        echo "common key binding: prefix+I for install plugin; prefix+U for udpate "

    }

    installEnhancedTools() {
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install
    }

    installGithub() {
        if [ "$release" -eq "ubuntu" ] || [ "$release" -eq "debian"]; then
            type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
                sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
                sudo apt update &&
                sudo apt install gh -y
        elif [ $os == "centos" ]; then
            sudo dnf install 'dnf-command(config-manager)'
            sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
            sudo dnf install gh
        else
            echoContent red " ---> you may need to install it mannually, \
            see https://github.com/cli/cli/blob/trunk/docs/install_linux.md#fedora-centos-red-hat-enterprise-linux-dnf"
        fi
    }

    removeBasicTools() {
        echo
    }

    installBasicTools
    installNVim
    installTmux
    installEnhancedTools
    installGithub
}

# install ohmyzsh
setupShell() {

    echoContent green " ---> installing zsh and ohmyzsh"
    command_exists zsh && echoContent green " ---> zsh have been installed, nothing installed"
    command_exists zsh || {
        ${installType} zsh >/dev/null 2>${errLogFile}
    }
    command_exists zsh || {
        echoContent red " ---> zsh installation failed, see ${errLogFile} for details"
        return
    }
    echoContent green " ------------> configuring ohmyzsh"
    execute_with_timeout "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 60 "Network timeout when installing ohmyzsh"
    chsh -s /usr/bin/zsh

    echoContent green " ------------> installing auto suggestion "
    execute_with_timeout "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 60 "Network timeout when cloning zsh-autosuggestions"

    echoContent green " ------------> installing auto suggestion "
    execute_with_timeout "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" 60 "Network timeout when cloning zsh-syntax-highlighting"

    # echoContent green " ------------> configuring ohmyzsh"
    # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # chsh -s /usr/bin/zsh

    # echoContent green " ------------> installing auto suggestion "
    # git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    # echoContent green " ------------> installing auto suggestion "
    # git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    echoContent green " ------------> installing MRU, easy to access recently used files or directory"
    git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z

    echoContent green " ------------> installing install powerlevel10k, a more comfotable theme, style for ohmyzsh"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    \sed -ri 's~(plugins=(.*)~plugins=(zsh-autosuggestions yum git extract tmux golang zsh-syntax-highlighting colored-man-pages colorize pip sudo httpie gitignore zsh-z autojump \3~g' ~/.zshrc

    sudo \cp ${modernEnvHomeDir}/global_aliases /etc/
    sudo \cp ${modernEnvHomeDir}/$shellProfile /etc/
    echo "source /etc/" >>$shellProfile

    source $shellProfile
}

# install programming language environment, based on your choice
setup_prog_lang() {

    installBash() {
        # unittest tool
        echoContent green " ---> installing bash unit test tool: bats"
        pushd /tmp
        git clone https://github.com/bats-core/bats-core.git
        cd bats-core
        sudo ./install.sh $globalInstallDir 1>/dev/null 2>${errLogFile}
        popd

        command_exists bats || {
            echoContent red " ---> bats installation failed, see ${errLogFile} for details"
            return
        }
    }

    installPython() {

        # install pyenv
        echoContent green " ---> installing pyenv"

        command_exists pyenv && {
            echoContent green " ---> pyenv have been installed, nothing installed"
        }

        command_exists pyenv || {
            curl https://pyenv.run | bash 1>/dev/null 2>${errLogFile}
            echoContent green " ---> setting up pyenv, add env var to $shellProfile"

            # TODO
            echo "" >$shellProfile
            echo "" >$shellProfile
            # 不知道这样对不对，需要转义字符不， TODO
            checkAndAddLine "export PATH=/usr/local/bin:\$PATH" "$shellProfile"
            checkAndAddLine '########## pyenv config' $shellProfile
            checkAndAddLine 'export PYENV_ROOT="$HOME/.pyenv"' $shellProfile
            checkAndAddLine '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' $shellProfile
            checkAndAddLine 'eval "$(pyenv init -)"' $shellProfile
            source $shellProfile
        }

        command_exists pyenv || {
            echoContent red " ---> pyenv installtion failed, python have not been installed, see ${errLogFile} for details"
            return
        }

        latestVersion=$(pyenv install --list | grep -v - | grep -v b | tail -2 | head -1)
        # install
        pyenv install ${latestVersion}
        pyenv global ${latestVersion}

        # configure
        echoContent green """ ---> setting up python, you can choose your own pip mirror site by
running pip config set global.index-url default is https://pypi.tuna.tsinghua.edu.cn/simple
        """
        pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

        echoContent green " ---> installing ipython: an interactive shell with syntax-highlighting for python"
        command_exists ipython && echoContent green " ---> ipython have been installed, nothing installed"
        command_exists ipython || pip install ipython 1>/dev/null 2>${errLogFile}
        command_exists ipython || echoContent red " ---> ipython installation failed, see ${errLogFile} for details"

        echoContent green """ ---> installing common python packages, including:
lxml
ipaddress
python-dateutil
apscheduler
mycli
aiohttp
datetime
timeit
docker-compose
chardet
supervisor
python-dateutil
        """

        pip install lxml >/dev/null 2>&1
        pip install ipaddress >/dev/null 2>&1
        pip install python-dateutil >/dev/null 2>&1
        pip install apscheduler >/dev/null 2>&1
        pip install mycli >/dev/null 2>&1
        pip install aiohttp >/dev/null 2>&1
        pip install datetime >/dev/null 2>&1
        pip install timeit >/dev/null 2>&1
        pip install docker-compose >/dev/null 2>&1
        pip install chardet >/dev/null 2>&1
        pip install supervisor >/dev/null 2>&1
        pip install python-dateutil >/dev/null 2>&1

        ############## pyenv 使用 ##############
        ## pyenv安装不同版的python
        #pyenv install 2.7.14
        #pyenv install 3.5.5

        ## 查看当前环境中已安装的python版本
        #pyenv versions

        ## 设置当前进程及子进程使用的python版本
        #pyenv shell 2.7.14

        ## 设置当前目录及子目录中使用的python版本
        #pyenv local 2.7.14

        ############## pyenv 使用 ##############
    }

    # 未完成
    removePython() {
        echoContent green " ---> are you sure you want to uninstall python? [y/n]"
        read answer
        if [ "$answer" != "${answer#[Yy]}" ]; then
            echo "uninstalling pyenv and everything related, which is rm -rf ~/.pyenv"
            rm -rf ~/.pyenv
            \sed -rin '/########## pyenv config/d' $shellProfile
            \sed -rin '/export PYENV_ROOT/d' $shellProfile
            \sed -rin '/\[\[ \- \$PYENV_ROOT\/bin \]\] && export/d' $shellProfile
            \sed -rin '/eval "\$\(pyenv init \-\)"/d' $shellProfile
        else
            echo "aborted" fi
        fi
    }

    installGolang() {

        echoContent green " ---> installing golang programming language environment"
        echoContent green " ---> Downloading golang package"
        command_exists go && {
            echoContent green " ---> golang have been installed, nothing installed"
            return
        }
        pushd /tmp
        case $os in
        "linux")
            case $arch in
            "amd64")
                archVariant=amd64
                ;;
            "x86_64")
                archVariant=amd64
                ;;
            "aarch64")
                archVariant=arm64
                ;;
            "armv6" | "armv7l")
                archVariant=armv6l
                ;;
            "armv8")
                archVariant=arm64
                ;;
            "i686")
                archVariant=386
                ;;
            .*386.*)
                archVariant=386
                ;;
            esac
            platform="linux-$archVariant"
            ;;
        "Darwin")
            case $arch in
            "x86_64")
                archVariant=amd64
                ;;
            "arm64")
                archVariant=arm64
                ;;
            esac
            platform="darwin-$archVariant"
            ;;
        esac

        if [ -z "$platform" ]; then
            echo "Your operating system is not supported by the script."
            return
        fi

        version=$(curl -Ls https://golang.org/dl/ |
            grep -oP 'go([0-9\.]+)\.linux-amd64\.tar\.gz' |
            grep -oP 'go[0-9\.]+' |
            head -n 1 |
            sed 's/.$//')

        packageName=$(curl -Ls https://go.dev/dl | grep -oP "go([0-9\.]+)\.${os}-${archVariant}\.tar\.gz" | head -n 1)
        if [ -z "$packageName" ]; then
            echoContent red \
                " ---> golang doesn't not support your system and architecture: ${os}-${archVariant}, nothing installed"
            return
        fi

        curl -LsSO "https://golang.org/dl/${packageName}"
        sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf ${packageName}
        popd

        command_exists go || {
            echoContent red " ---> golang installtion failed, see ${errLogFile} for details"
            return
        }

        echoContent green " ---> setting up golang environment, including gopath: $HOME/projs, $HOME/go, installing gotools"

        for dir in ~/go/{bin,pkg,src}; do
            [ ! -d "$dir" ] && mkdir -p "$dir"
        done
        for dir in ~/projs/{bin,pkg,src}; do
            [ ! -d "$dir" ] && mkdir -p "$dir"
        done

        {
            echo ""
            echo ""
        } >>$shellProfile

        checkAndAddLine '########## golang config' $shellProfile
        checkAndAddLine 'export GOROOT='/usr/local/go'' $shellProfile
        checkAndAddLine 'export PATH=$PATH:$GOROOT/bin' $shellProfile
        checkAndAddLine 'export GOPATH=$HOME/go:$HOME/projs' $shellProfile
        checkAndAddLine 'export GOPROXY=direct' $shellProfile

        source $shellProfile

        go install -v github.com/mdempsky/gocode@latest
        go install -v github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest
        go install -v github.com/ramya-rao-a/go-outline@latest
        go install -v github.com/acroca/go-symbols@latest
        go install -v golang.org/x/tools/cmd/guru@latest
        go install -v golang.org/x/tools/cmd/gorename@latest
        go install -v github.com/go-delve/delve/cmd/dlv@latest
        go install -v github.com/stamblerre/gocode@latest
        go install -v github.com/rogpeppe/godef@latest
        go install -v github.com/sqs/goreturns@latest
        go install -v golang.org/x/lint/golint@latest
        go install -v github.com/cweill/gotests/...@latest
        go install -v github.com/fatih/gomodifytags@latest
        go install -v github.com/josharian/impl@latest
        go install -v github.com/davidrjenni/reftools/cmd/fillstruct@latest
        go install -v github.com/haya14busa/goplay/cmd/goplay@latest
        go install -v github.com/godoctor/godoctor@latest
    }

    uninstall_golang() {
        rm -rf "$GOROOT"
        if [ "$os" == "Darwin" ]; then
            if [ "$shell" == "fish" ]; then
                sed -i "" '/# GoLang/d' "$shellProfile"
                sed -i "" '/set GOROOT/d' "$shellProfile"
                sed -i "" '/set GOPATH/d' "$shellProfile"
                sed -i "" '/set PATH $GOPATH\/bin $GOROOT\/bin $PATH/d' "$shellProfile"
            else
                sed -i "" '/# GoLang/d' "$shellProfile"
                sed -i "" '/export GOROOT/d' "$shellProfile"
                sed -i "" '/$GOROOT\/bin/d' "$shellProfile"
                sed -i "" '/export GOPATH/d' "$shellProfile"
                sed -i "" '/$GOPATH\/bin/d' "$shellProfile"
            fi
        else
            if [ "$shell" == "fish" ]; then
                sed -i '/# GoLang/d' "$shellProfile"
                sed -i '/set GOROOT/d' "$shellProfile"
                sed -i '/set GOPATH/d' "$shellProfile"
                sed -i '/set PATH $GOPATH\/bin $GOROOT\/bin $PATH/d' "$shellProfile"
            else
                sed -i '/# GoLang/d' "$shellProfile"
                sed -i '/export GOROOT/d' "$shellProfile"
                sed -i '/$GOROOT\/bin/d' "$shellProfile"
                sed -i '/export GOPATH/d' "$shellProfile"
                sed -i '/$GOPATH\/bin/d' "$shellProfile"
            fi
        fi
    }

    install_java() {
        # ebuntu 一键配置JDK环境
        echo -e "开始安装Java"
        apt-get install python-software-properties >/dev/null 2>&1
        add-apt-repository ppa:linuxuprising/java >/dev/null 2>&1
        apt-get update >/dev/null 2>&1
        apt-get install oracle-java8-installer >/dev/null 2>&1
        apt install oracle-java8-set-default >/dev/null 2>&1

        # 手动配置 java
        if command -v java >/dev/null 2>&1; then
            test
        else
            echo -e "自动安装Java失败，将切换为手动安装"
            # wget https://github.com/al0ne/LinuxCheck/raw/master/rkhunter.tar.gz >/dev/null 2>&1
            # tar -xzvf jdk.tar.gz
            # mv jdk1.8.0_251 /opt
            # echo "export JAVA_HOME=/opt/jdk1.8.0_251" >>~/.zshrc
            # echo "export CLASSPATH=.:${JAVA_HOME}/lib" >>~/.zshrc
            # echo "export PATH=${JAVA_HOME}/bin:$PATH" >>~/.zshrc
            # source ~/.zshrc
            # update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_251/bin/java 1
            # update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_251/bin/javac 1
            # update-alternatives --set java /opt/jdk1.8.0_251/bin/java
            # update-alternatives --set javac /opt/jdk1.8.0_251/bin/javac

        fi
    }

}

# 开发环境配置
setup_dev_env() {

    installDocker() {

        command_exists docker &&
            echoContent green " ---> docker have been installed, nothing installed" && return

        command_exists docker || {
            pushd /tmp
            echoContent green " ---> installing docker"
            curl -fsSL https://get.docker.com -o get-docker.sh 2>${errLogFile} 1>/dev/null
            sudo sh get-docker.sh
            popd
        }

        command_exists docker || {
            echoContent red " ---> docker installtion failed, see ${errLogFile} for details"
            return
        }

        iswsl2=$(uname -r | grep -io wsl2)
        if [ -n "$iswsl2" ]; then
            echoContent red \
                " ---> It seems your system is wsl2, please check your C:\Users\yourname\.wslconfig file \
                to see if it have enabled mirror network mode, if so, \
                you'll have to add the following key-value to /etc/docker/daemon.json, \
                then reload it to make it effective \
                with command 'sudo systemctl daemon-reload && sudo systemctl restart docker', see \
                https://github.com/microsoft/WSL/issues/10494"
            echo '"iptables": false'
        fi

        # config user authorization so that non root user directly use docker command
        echoCOntent green " ---> configuring docker user authorization, in order to run \
        docker command without sudo:w"
        sudo groupadd docker
        gpasswd -a ${USER} docker
        sudo systemctl restart docker
        sudo chmod a+rw /var/run/docker.sock
    }

    installNodejsByNvm() {
        command_exists node &&
            echoContent green " ---> nodejs have been installed, nothing installed" && return

        command_exists node || {
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash2 >${errLogFile} 1>/dev/null
            nvm install node
            nvm use node
        }

        command_exists node || {
            echoContent red " ---> nodejs installtion failed, see ${errLogFile} for details"
            return
        }
    }

    k8s() {

        # 镜像源配置
        proxychains4 wget
        sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        sudo apt-get install -y conntrack

        # install cri-dockerd
        git clone https://github.com/Mirantis/cri-dockerd.git
        cd cri-dockerd
        mkdir bin
        go get && go build -o bin/cri-dockerd
        mkdir -p /usr/local/bin
        install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
        cp -a packaging/systemd/* /etc/systemd/system
        sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
        systemctl daemon-reload
        systemctl enable cri-docker.service
        systemctl enable --now cri-docker.socket

        sudo minikube start --driver='none' --image-mirror-country='cn' --image-repository='registry.cn-hangzhou.aliyuncs.com/google_containers'

        # npm 源配置
        npm config set registry http://mirrors.cloud.tencent.com/npm/
        # npm config get registry
        # 如果返回http://mirrors.cloud.tencent.com/npm/，说明镜像配置成功。

    }

    installCommonDevLib() {

        # 常见库配置
        echoContent green " ----> installing libgeoip1"
        ${installType} libgeoip1 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing libgeoip-dev"
        ${installType} libgeoip-dev 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing openssl"
        ${installType} openssl 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing libcurl3-dev"
        ${installType} libcurl3-dev 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing libssl-dev"
        ${installType} libssl-dev 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing php"
        ${installType} php 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing net-tools"
        ${installType} net-tools 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing ifupdown"
        ${installType} ifupdown 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing tree"
        ${installType} tree 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing cloc"
        ${installType} cloc 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing python3-pip"
        ${installType} python3-pip 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing gcc"
        ${installType} gcc 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing gdb"
        ${installType} gdb 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing g++"
        ${installType} g++ 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing locate"
        ${installType} locate 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing shellcheck"
        ${installType} shellcheck 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing redis-cli"
        ${installType} redis-cli 1>/dev/null 2>${errLogFile}
        echoContent green " ----> installing redis-server"
        ${installType} redis-server 1>/dev/null 2>${errLogFile}

    }
}

setupDataIntensiveAppServerDependencies() {

    install_scala() {
        wget https://downloads.lightbend.com/scala/2.12.15/scala-2.12.15.rpm
        curl -L --output $TMPDIR/scala-2.12.15.rpm https://downloads.lightbend.com/scala/2.12.15/scala-2.12.15.rpm
        sudo yum install $TMPDIR/scala-2.12.15.rpm
        rm $TMPDIR/scala-2.12.15.rpm
    }

    install_java() {
        # java8 用于跟hadoop 配合, java17(latest) 用于充当 java language server
        # 到官网下载 java https://www.oracle.com/java/technologies/downloads/#java8
        tar -C $HOME/opt -xzf $PACKAGE_DIR/jdk-8u311-linux-x64.tar.gz
        tee -a $HOME/.zshrc >/dev/null <<EOT
# java jdk
export JAVA_HOME=$HOME/opt/jdk1.8.0_311
export JRE_HOME=$JAVA_HOME/jre
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=./://$JAVA_HOME/lib:$JRE_HOME/lib
EOT

        # 安裝 maven
        curl -L --output $TMPDIR/apache-maven-4.6.3-bin.tar.gz https://mirrors.aliyun.com/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
        tar -C $HOME/opt/ -xzf $TMPDIR/apache-maven-3.6.3-bin.tar.gz

        tee -a $HOME/.zshrc >/dev/null <<EOT
# java maven
export M2_HOME=$HOME/opt/apache-maven-3.6.3
export MAVEN_HOME=${M2_HOME}
export MAVEN_BIN=${M2_HOME}/bin/
export PATH=${PATH}:${MAVEN_HOME}:${MAVEN_BIN}
EOT

        # 配置鏡像源
        tmpfile=$(mktemp)
        tee $tmpfile >>/dev/null <<EOT
<mirror>
    <id>aliyunmaven</id>
    <mirrorOf>*</mirrorOf>
    <name>阿里云公共仓库</name>
    <url>https://maven.aliyun.com/repository/public</url>
</mirror>
EOT
        sed -i "/<mirrors>/r $tmpfile" $HOME/opt/apache-maven-3.6.3/conf/settings.xml
        \rm -rf $tmpfile

    }

    install_hadoop() {
        # hadoop
        export HADOOP_HOME=$HOME/opt/hadoop-2.10.1
        export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
    }

    install_zookeeper() {
        # curl -L "https://mirrors.aliyun.com/apache/zookeeper/stable/apache-zookeeper-3.6.3.tar.gz" -o $TMPDIR/apache-zookeeper-3.6.3.tar.gz
        curl -L "https://mirrors.aliyun.com/apache/zookeeper/stable/apache-zookeeper-3.6.3-bin.tar.gz" -o $TMPDIR/apache-zookeeper-3.6.3-bin.tar.gz
        tar -C $OPT -xzf $TMPDIR/apache-zookeeper-3.6.3-bin.tar.gz
        tee -a ~/.zshrc >/dev/null <<EOT
export ZOOKEEPER_HOME=$HOME/opt/apache-zookeeper-3.6.3
export PATH=$PATH:$ZOOKEEPER_HOME/bin
EOT

        # 修改配置文件
        cd $HOME/opt/apache-zookeeper-3.6.3/conf
        cp zoo_sample.cfg zoo.cfg
        dataDir="/tmp/zookeeper/data"
        dataLogDir="/tmp/zookeeper/log"
        mkdir $dataDir $dataLogDir
        sed -i '/^data.*/d' zoo.cfg
        tee -a zoo.cfg >/dev/null <<EOT
dataDir=/tmp/zookeeper/data
dataLogDir=/tmp/zookeeper/log
EOT

        # 配置服务器编号
        echo 0 >$dataDir/myid
    }

    installRedis() {
        # install server.
        sudo apt update
        sudo apt install -y redis redis-server
        sudo systemctl start redis-server

        curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
        sudo apt-get update
        sudo apt-get install redis

        curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
        sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
        sudo apt-get update
        sudo apt-get install redis-stack-server

        # install iredis client with syntax highlight and auto completion
        pip install iredis
    }

    install_mysql() {
        set -x
        set -e

        # remove previous mysql  installation
        echo remove previous mysql installation
        rpm -qa | \grep mysql | xargs -n 1 -I _ sudo yum autoremove -y _
        #sudo yum list installed | \grep mysql | awk '{print $1}'  | xargs sudo yum remove -y
        if [ -f /etc/mysql ]; then
            sudo rm /etc/mysql
        fi
        if [ -f /etc/my.cnf ]; then
            sudo rm /etc/my.cnf
        fi
        if [ -f $HOME/.my.cnf ]; then
            rm $HOME/.my.cnf
        fi

        cd $TMPDIR

        # 在线安装
        #wget https://dev.mysql.com/get/mysql80-community-release-el7-4.noarch.rpm # mysql8.x 版本提示缺库 lib.so glibc.2.28
        #wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm # mysql 5.7 版本可安装
        # 安装 mysql 源
        #sudo yum localinstall mysql80-community-release-el8-2.noarch.rpm
        sudo yum localinstall mysql80-community-release-el7-4.noarch.rpm # 查看启用的版本
        sudo yum repolist enabled | grep "mysql.*-community.*"
        # 查看启用的版本
        sudo yum repolist enabled | grep mysql
        # dependencies
        sudo yum install libaio
        # 安装mysql
        sudo yum install mysql-community-server
        # 查看是否安装成功
        # 好像此方法可以用来查看工具是否安装成功
        command -v mysql
        mysql --version

        # login with root id and change password
        # create user, alter passwd

        # 离线安装 解决在线安装缺库的错误
        wget https://mirrors.aliyun.com/mysql/MySQL-8.0/mysql-8.0.27-1.el7.x86_64.rpm-bundle.tar
        tar xf mysql-8.0.27-1.el7.x86_64.rpm-bundle.tar
        sudo yum install mysql-community-{client,common,devel,embedded,libs,server}-*

        # 修改root密码，创建bae账号，初始化数据库, 并赋予bae账号所有权限
        touch db_init.sql
        tee db_init.sql >/dev/null <<EOT
-- by root
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Root@123456';
CREATE USER 'bae'@'localhost' IDENTIFIED BY 'Bae@111111';
-- create database my_netdisk;
create database test;
-- GRANT ALL ON my_netdisk.* TO 'bae'@'localhost';
-- GRANT ALL ON test.* TO 'bae'@'localhost';
GRANT ALL ON *.* TO 'bae'@'localhost';
EOT

        echo "latest account info"
        echo root@localhost Root@123456
        echo bae@localhost Bae@111111
        echo starting mysqld
        systemctl start mysqld
        PASSWD=$(sudo grep 'temporary password' /var/log/mysqld.log | grep -o 'root.*' | awk '{print $2}')
        mysql --connect-expired-password -uroot -p$PASSWD <db_init.sql

        # config mysql, 可以自动补全
        touch $HOME/.my.cnf
        tee $HOME/.my.cnf >/dev/null <<EOT
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/8.0/en/server-configuration-defaults.html

[mysql]
    auto-rehash

[mysqld]
# GENERAL
datadir                                  = /var/lib/mysql
socket                                   = /var/lib/mysql/mysql.sock
pid_file                                 = /var/lib/mysql/mysql.pid
user                                     = mysql
port                                     = 3306
# INNODB
# innodb_dedicated_server is a new variable intrduced by mysql 8.0, which can 
# automatically detect the memory size of server and adjust the following four 
# setting variables at the beginning of starting mysql.
innodb_buffer_pool_size                  = 1024 # 乱填的
innodb_log_file_size                     = 1024 # 乱填的
innodb_file_per_table                    = 1
innodb_flush_method                      = O_DIRECT
# LOGGING
log_error                                = /var/lib/mysql/mysql-error.log
log_slow_queries                         = /var/lib/mysql/mysql-slow.log
# OTHER
tmp_table_size                           = 32M
max_heap_table_size                      = 32M
max_connections                          = 1024 # 乱填的
thread_cache_size                        = 1024 # 乱填的
table_open_cache                         = 1024 # 乱填的
open_files_limit                         = 65535

[client]
socket                                   = /var/lib/mysql/mysql.sock
port                                     = 3306
EOT

        echo "installing mycli mysql client shell with autocompletion and syntax highlight function"
        pip3 install -U mycli
        echo "try it now with command: mycli -uuser -ppasswd"

        # 清理文件
        echo clean tmp files
        rm db_init.sql
        rm mysql-8.0.27-1.el7.x86_64.rpm-bundle.tar

        sudo groupadd mysql
        sudo useradd -r -g mysql -s /bin/false mysql

        #cd /usr/local
        #tar xvf /path/to/mysql-VERSION-OS.tar.xz
        #ln -s full-path-to-mysql-VERSION-OS mysql
        #cd mysql
        #mkdir mysql-files
        #chown mysql:mysql mysql-files
        #chmod 750 mysql-files
        #bin/mysqld --initialize --user=mysql
        #bin/mysql_ssl_rsa_setup
        #bin/mysqld_safe --user=mysql &
        ## ext command is optional
        #cp support-files/mysql.server /etc/init.d/mysql.server

        # 下载测试数据并安装
        # 参考网址 https://dev.mysql.com/doc/index-other.html
        # sakila-db: https://dev.mysql.com/doc/sakila/en/sakila-installation.html
        cd $TMPDIR
        proxychains4 curl -L 'https://downloads.mysql.com/docs/sakila-db.tar.gz' -o sakila-db.tar.gz
        tar xzf sakila-db.tar.gz
        cd sakila-db
        mysql --connect-expired-password -uroot -pRoot@123456 <sakila-schema.sql
        mysql --connect-expired-password -uroot -pRoot@123456 <sakila-data.sql
        cd ..
        rm sakila-db.tar.gz
        rm -rf sakila-db
    }
}

setupDisk() {
    installRclone() {
        echoContent green " ---> installing rclone"
        curl https://rclone.org/install.sh | sudo bash
        rclone config
    }

    installAlist() {
        echo
        # echoContent green " ---> installing alist, suitable for x86_64"
        # curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install
        # case $arch in
        # "x86_64")
        #     arch=amd64
        #     ;;
        # "arm64")
        #     arch=arm64
        #     ;;
        # esac
    }

}

vpsSwissArmyKnife() {

    # VPS规格测试
    wget -qO- bench.sh | bash
    # 或者：
    wget -qO- git.io/superbench.sh | bash
    # GB5-6
    # GB6 跑分脚本，附带宽测试：
    curl -sL yabs.sh | bash
    # GB6 剔除带宽测试，因为都是国外节点测试，国内跑没多大意义：
    curl -sL yabs.sh | bash -s -- -i
    # GB5 跑分脚本，附带宽测试：
    curl -sL yabs.sh | bash -5
    # GB5 剔除带宽测试：
    curl -sL yabs.sh | bash -s -- -i -5
    # 三网测速
    bash <(curl -sL bash.icu/speedtest)
    bash <(curl -Lso- https://bench.im/hyperspeed)
    bash <(curl -Lso- https://www.infski.com/files/superspeed.sh)
    # 回程路由
    wget -N --no-check-certificate https://raw.githubusercontent.com/Chennhaoo/Shell_Bash/master/AutoTrace.sh && chmod +x AutoTrace.sh && bash AutoTrace.sh
    wget -qO- git.io/besttrace | bash
    # 流媒体解锁
    bash <(curl -L -s check.unlock.media)
    wget -qO- https://github.com/yeahwu/check/raw/main/check.sh | bash
    # 25端口
    telnet smtp.aol.com 25
    # 独服硬盘测试
    wget -q https://github.com/Aniverse/A/raw/i/a && bash a
    # vps去程测试网址：https://tools.ipip.net/traceroute.php
    # vps的ping测试网址：https://ping.pe
    # 俺的脚本
    # 自用DD脚本：
    # https://github.com/yeahwu/InstallOS
    # 一键代理脚本：
    # https://github.com/yeahwu/v2ray-wss

}

setupNetwork() {

    installProxyServer() {
        wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
    }

    install_proxychains() {
        pushd /tmp
        git clone https://github.com/rofl0r/proxychains-ng.git
        cd proxychains-ng
        make -j 8
        sudo make install
        mkdir ~/.proxychains
        echo '[ProxyList]' >>proxychains.conf
        echo 'socks5  192.168.0.103 10080' >>proxychains.conf
        ./configure --prefix=/usr --sysconfdir=/etc
        #export http_proxy="http://192.168.0.102:7890"
        #export https_proxy="http://192.168.0.102:7890"
        popd
    }

    setup_proxy_network() {
        export http_proxy='http://127.0.0.1:7891'
        export https_proxy='http://127.0.0.1:7891'
    }

    install_hacker() {
        # 网络安全配置
        echo -e "正在安装 nmap ..."
        apt install -y nmap >/dev/null 2>&1
        echo -e "正在安装 netcat ..."
        apt install -y netcat >/dev/null 2>&1
        echo -e "正在安装 masscan ..."
        apt install -y masscan >/dev/null 2>&1
        echo -e "正在安装 zmap ..."
        apt install -y zmap >/dev/null 2>&1
        echo -e "正在安装 dnsutils ..."
        apt install -y dnsutils >/dev/null 2>&1
        echo -e "正在安装 wfuzz ..."
        pip install wfuzz >/dev/null 2>&1
        # 安装 weevely3
        if [ -d "/opt/weevely3" ]; then
            echo -e "检测到weevely3已安装将跳过"
        else
            echo -e "正在克隆 weevely3 ..."
            cd /opt && git clone https://github.com/epinna/weevely3.git >/dev/null 2>&1
            echo 'alias weevely=/opt/weevely3/weevely.py' >>~/.zshrc
        fi
        # 安装 whatweb
        if [ -d "/opt/whatweb" ]; then
            echo -e "检测到whatweb已安装将跳过"
        else
            echo -e "正在克隆 whatweb ..."
            cd /opt && git clone https://github.com/urbanadventurer/WhatWeb.git >/dev/null 2>&1
            echo 'alias whatweb=/opt/WhatWeb/whatweb' >>~/.zshrc
        fi
        # 安装 OneForAll
        if [ -d "/opt/OneForAll" ]; then
            echo -e "检测到OneForAll已安装将跳过"
        else
            echo -e "正在克隆 OneForAll ..."
            cd /opt && git clone https://github.com/shmilylty/OneForAll.git >/dev/null 2>&1
        fi
        # 安装 dirsearch
        if [ -d "/opt/dirsearch" ]; then
            echo -e "检测到dirsearch已安装将跳过"
        else
            echo -e "正在克隆 dirsearch ..."
            cd /opt && git clone https://github.com/shmilylty/OneForAll.git >/dev/null 2>&1
        fi
        # 安装 httpx
        if command -v httpx >/dev/null 2>&1; then
            echo -e "检测到已安装httpx 将跳过！"
        else
            echo -e "开始安装Httpx"
            GO111MODULE=on go get -u -v github.com/projectdiscovery/httpx/cmd/httpx >/dev/null 2>&1

        fi
        # 安装 subfinder
        if command -v subfinder >/dev/null 2>&1; then
            echo -e "检测到已安装subfinder 将跳过！"
        else
            echo -e "开始安装subfinder"
            GO111MODULE=on go get -u -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder >/dev/null 2>&1

        fi
        # 安装 nuclei
        if command -v nuclei >/dev/null 2>&1; then
            echo -e "检测到已安装nuclei 将跳过！"
        else
            echo -e "开始安装nuclei"
            GO111MODULE=on go get -u -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei >/dev/null 2>&1

        fi
        # 安装 naabu
        if command -v naabu >/dev/null 2>&1; then
            echo -e "检测到已安装 naabu 将跳过！"
        else
            echo -e "开始安装 naabu"
            GO111MODULE=on go get -u -v github.com/projectdiscovery/naabu/v2/cmd/naabu >/dev/null 2>&1

        fi
        # 安装 dnsx
        if command -v dnsx >/dev/null 2>&1; then
            echo -e "检测到已安装 dnsx 将跳过！"
        else
            echo -e "开始安装 dnsx"
            GO111MODULE=on go get -u -v github.com/projectdiscovery/dnsx/cmd/dnsx >/dev/null 2>&1

        fi
        # 安装 subjack
        if command -v subjack >/dev/null 2>&1; then
            echo -e "检测到已安装 subjack 将跳过！"
        else
            echo -e "开始安装 subjack"
            go get github.com/haccer/subjack >/dev/null 2>&1

        fi
        # 安装 ffuf
        if command -v ffuf >/dev/null 2>&1; then
            echo -e "检测到已安装 ffuf 将跳过！"
        else
            echo -e "开始安装 ffuf"
            go get -u github.com/ffuf/ffuf >/dev/null 2>&1

        fi

    }

}

# 检查wget showProgress
checkWgetShowProgress() {
    if find /usr/bin /usr/sbin | grep -q -w wget && wget --help | grep -q show-progress; then
        wgetShowProgressStatus="--show-progress"
    fi
}

# 主菜单
menu() {

    cd "$HOME" || exit
    echoContent red "\n=============================================================="
    echoContent green "作者：russel"
    echoContent green "当前版本：v0.1"
    echoContent green "Github：https://github.com/RussellLoveCoding"
    echoContent green "描述: Linux 初始化\c"
    checkWgetShowProgress
    echoContent red "=============================================================="
    if [[ -n "${coreInstallType}" ]]; then
        echoContent yellow "1.重新安装"
    else
        echoContent yellow "1.安装"
    fi

    echoContent yellow "2.任意组合安装"

    echoContent yellow "4.Hysteria2管理"
    echoContent yellow "5.REALITY管理"
    echoContent yellow "6.Tuic管理"
    echoContent yellow "7.账号管理"
    echoContent red "=============================================================="
    mkdirTools

    read -r -p "请选择:" selectInstallType
    case ${selectInstallType} in
    1)
        selectCoreInstall
        ;;
    2)
        selectCoreInstall
        ;;
    3)
        initXrayFrontingConfig 1
        ;;
    4)
        manageHysteria
        ;;
    5)
        manageReality 1
        ;;
    esac
}
# printHeader
# menu

# tmptestfile="/tmp/tmptestfile"
# echo "line1" > $tmptestfile
# Call the function with a line that does not exist in the file
# checkAndAddLine $tmptestfile "line2"
# init
# setupShell
# setupBasicTools
