#!/usr/bin/env bash
set -e
source common.sh

installPkgBundle() {
    $upgrade
    $installType libsqlite3-dev liblzma-dev libbz2-dev libncurses5-dev libffi-dev libreadline-dev libssl-dev
}

installGithub() {
    # echoContent skyBlue "\n Progress $1/${totalProgress} : installing basic tools"
    command_exists gh && echoContent green " ---> gh have been installed, nothing installed" && return
    case "$distro" in
    "centos")
        sudo dnf install 'dnf-command(config-manager)'
        sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
        sudo dnf install gh
        ;;
    "debian")
        type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
            sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
            $upgrade 1>/dev/null 2>&1 &&
            sudo apt install gh -y
        ;;
    "ubuntu")
        type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
            sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
            $upgrade 1>/dev/null 2>&1 &&
            sudo apt install gh -y
        ;;
    *)
        echoContent red " ---> you may need to install it mannually, \
                                                see https://github.com/cli/cli/blob/trunk/docs/install_linux.md#fedora-centos-red-hat-enterprise-linux-dnf"
        ;;
    esac
}

uninstallGithub() {
    command_exists gh || return
    case "$distro" in
    "centos")
        sudo dnf remove gh
        sudo dnf config-manager --disable gh-cli
        sudo dnf remove 'dnf-command(config-manager)'
        ;;
    "debian")
        sudo apt remove gh
        sudo rm /usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo rm /etc/apt/sources.list.d/github-cli.list
        ;;
    "ubuntu")
        sudo apt remove gh
        sudo rm /usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo rm /etc/apt/sources.list.d/github-cli.list
        ;;
    *)
        echoContent red " ---> you may need to uninstall it mannually"
        ;;
    esac
    if command_exists gh; then
        echoContent red " ---> uninstall gh failed, see ${errLogFile} for details"
    else
        echoContent green " ---> gh have been uninstalled"
    fi
}

# install programming language environment, based on your choice

installBatscore() {
    # unittest tool
    echoContent green " ---> installing bash unit test tool: bats"
    pushd /tmp
    git clone https://github.com/bats-core/bats-core.git
    cd bats-core
    sudo ./install.sh $globalInstallDir 1>/dev/null
    cd ..
    rm -rf bats-core
    popd

    command_exists bats || {
        echoContent red " ---> bats installation failed, see ${errLogFile} for details"
        return
    }
}

uninstallBatscore() {
    curl -s -S -L https://raw.githubusercontent.com/bats-core/bats-core/master/uninstall.sh | bash 1>/dev/null
}

installPythonByPyenv() {

    # install pyenv
    echoContent green " ---> installing pyenv"

    # Here on centos distribution, packages name might be slightly different.
    command_exists pyenv && {
        echoContent green " ---> pyenv have been installed, nothing installed"
    }

    if ! command_exists pyenv; then
        echoContent green " ---> setting up pyenv, add env var to $shellProfile"
        curl -s -S -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash 1>/dev/null
        echoContent green " ----> you need to manually add pyenv source code to shell profile and then rerun this script"
        exit 0
    fi

    command_exists pyenv || {
        echoContent red " ---> pyenv installtion failed, python have not been installed, see ${errLogFile} for details"
        return
    }

    # installing the necessary dependencies for building Python, since Python from source code
    # if you run `pyenv install version`

    # install latest python version
    echoContent green " -----> installing dependencies for pyenv to install python"
    $upgrade 1>/dev/null
    ${installType} libsqlite3-dev liblzma-dev libbz2-dev libncurses5-dev libffi-dev libreadline-dev libssl-dev 1>/dev/null
    $installType python3-pip 1>/dev/null 2>&1
    pip install --upgrade pip 1>/dev/null 2>&1

    if [ ! -d "$(pyenv root)"/plugins/pyenv-install-latest ]; then
        git clone https://github.com/momo-lab/pyenv-install-latest.git "$(pyenv root)"/plugins/pyenv-install-latest
    fi
    latest_version=$(pyenv versions | tail -1 | sed 's/ //g')
    latestVersion=$(pyenv install --list | \grep -v - | \grep -v b | tail -2 | head -1) # avoiding using grep alias outputing line number
    pyenv install-latest
    pyenv global $latestVersion
    pip install --upgrade pip 1>/dev/null

    # configure
    echoContent green """ ---> setting up python, you can choose your own pip mirror site by
        running pip config set global.index-url default is https://pypi.tuna.tsinghua.edu.cn/simple
        """
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

    echoContent green " ---> installing ipython: an interactive shell with syntax-highlighting for python"
    command_exists ipython && echoContent green " ---> ipython have been installed, nothing installed"
    command_exists ipython || pip install ipython 1>/dev/null
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

    pip install lxml >/dev/null
    pip install ipaddress >/dev/null
    pip install python-dateutil >/dev/null
    pip install apscheduler >/dev/null
    pip install mycli >/dev/null
    pip install aiohttp >/dev/null
    pip install datetime >/dev/null
    pip install timeit >/dev/null
    pip install docker-compose >/dev/null
    pip install chardet >/dev/null
    pip install supervisor >/dev/null
    pip install python-dateutil >/dev/null

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

removePython() {
    # The simplicity of pyenv makes it easy to temporarily disable it, or uninstall from the system.
    # 1. To disable Pyenv managing your Python versions, simply remove the pyenv init invocations from your shell startup configuration. This will remove Pyenv shims directory from PATH, and future invocations like python will execute the system Python version, as it was before Pyenv.
    # pyenv will still be accessible on the command line, but your Python apps won't be affected by version switching.
    # 2. To completely uninstall Pyenv, remove all Pyenv configuration lines from your shell startup configuration, and then remove its root directory. This will delete all Python versions that were installed under the $(pyenv root)/versions/ directory:
    # rm -rf $(pyenv root)
    rm -rf $(pyenv root)
}

installGolang() {

    echoContent green " ---> installing golang programming language environment"
    echoContent green " ---> Downloading golang package"
    if command_exists go; then
        echoContent green " ---> golang have been installed, nothing installed"
        continue to configure
    else
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

    fi
    echoContent green " ---> setting up golang environment, including gopath: $HOME/projs, $HOME/go, installing gotools"

    for dir in ~/go/{bin,pkg,src}; do
        [ ! -d "$dir" ] && mkdir -p "$dir"
    done
    for dir in ~/projs/{bin,pkg,src}; do
        [ ! -d "$dir" ] && mkdir -p "$dir"
    done

    echoContent green " ---> installing gotools"
    go install -v github.com/mdempsky/gocode@latest 1>/dev/null 2>&1
    go install -v github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest 1>/dev/null 2>&1
    go install -v github.com/ramya-rao-a/go-outline@latest 1>/dev/null 2>&1
    go install -v github.com/acroca/go-symbols@latest 1>/dev/null 2>&1
    go install -v golang.org/x/tools/cmd/guru@latest 1>/dev/null 2>&1
    go install -v golang.org/x/tools/cmd/gorename@latest 1>/dev/null 2>&1
    go install -v github.com/go-delve/delve/cmd/dlv@latest 1>/dev/null 2>&1
    go install -v github.com/stamblerre/gocode@latest 1>/dev/null 2>&1
    go install -v github.com/rogpeppe/godef@latest 1>/dev/null 2>&1
    go install -v github.com/sqs/goreturns@latest 1>/dev/null 2>&1
    go install -v golang.org/x/lint/golint@latest 1>/dev/null 2>&1
    go install -v github.com/cweill/gotests/...@latest 1>/dev/null 2>&1
    go install -v github.com/fatih/gomodifytags@latest 1>/dev/null 2>&1
    go install -v github.com/josharian/impl@latest 1>/dev/null 2>&1
    go install -v github.com/davidrjenni/reftools/cmd/fillstruct@latest 1>/dev/null 2>&1
    go install -v github.com/haya14busa/goplay/cmd/goplay@latest 1>/dev/null 2>&1
    go install -v github.com/godoctor/godoctor@latest 1>/dev/null 2>&1
}

uninstall_golang() {
    rm -rf "$GOROOT"
    echoContent green "you need to remove environment variables in $shellProfile and 
    remove go path, like ~/go, ~/projs manually, since this may contain important data"
}

install_java() {
    # ebuntu 一键配置JDK环境
    echo -e "开始安装Java"
    apt-get install python-software-properties >/dev/null
    add-apt-repository ppa:linuxuprising/java >/dev/null
    apt-get update >/dev/null
    apt-get install oracle-java8-installer >/dev/null
    apt install oracle-java8-set-default >/dev/null

    # 手动配置 java
    if command -v java >/dev/null; then
        echo yes
    else
        echo -e "自动安装Java失败，将切换为手动安装"
        # wget https://github.com/al0ne/LinuxCheck/raw/master/rkhunter.tar.gz >/dev/null
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

# 开发环境配置
installNodejsByNvm() {
    # remove the default nodejs with old version
    if dpkg -S $(which node) &>/dev/null; then
        $removeType nodejs
    fi

    if command_exists node; then
        echoContent green " ---> nodejs have been installed, nothing installed" && return
    else
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash 1>/dev/null 2>>${errLogFile}
        nvm install node
        nvm use node
    fi

    command_exists node || {
        echoContent red " ---> nodejs installtion failed, see ${errLogFile} for details"
        return
    }
}

uninstallNvm() {
    rm -rf "$NVM_DIR"
}

installCommonDevLib() {

    # 常见库配置
    echoContent green " ----> installing libgeoip1"
    ${installType} libgeoip1 1>/dev/null
    echoContent green " ----> installing libgeoip-dev"
    ${installType} libgeoip-dev 1>/dev/null
    echoContent green " ----> installing openssl"
    ${installType} openssl 1>/dev/null
    echoContent green " ----> installing libcurl3-dev"
    ${installType} libcurl3-dev 1>/dev/null
    echoContent green " ----> installing libssl-dev"
    ${installType} libssl-dev 1>/dev/null
    echoContent green " ----> installing php"
    ${installType} php 1>/dev/null
    echoContent green " ----> installing net-tools"
    ${installType} net-tools 1>/dev/null
    echoContent green " ----> installing ifupdown"
    ${installType} ifupdown 1>/dev/null
    echoContent green " ----> installing tree"
    ${installType} tree 1>/dev/null
    echoContent green " ----> installing cloc"
    ${installType} cloc 1>/dev/null
    echoContent green " ----> installing python3-pip"
    ${installType} python3-pip 1>/dev/null
    echoContent green " ----> installing gcc"
    ${installType} gcc 1>/dev/null
    echoContent green " ----> installing gdb"
    ${installType} gdb 1>/dev/null
    echoContent green " ----> installing g++"
    ${installType} g++ 1>/dev/null
    echoContent green " ----> installing locate"
    ${installType} locate 1>/dev/null
    echoContent green " ----> installing shellcheck"
    ${installType} shellcheck 1>/dev/null
    echoContent green " ----> installing redis-cli"
    ${installType} redis-cli 1>/dev/null
    echoContent green " ----> installing redis-server"
    ${installType} redis-server 1>/dev/null

}

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

installRclone() {
    echoContent green " ---> installing rclone"
    curl https://rclone.org/install.sh | sudo bash
    rclone config
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