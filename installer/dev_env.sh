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
            sudo apt update &&
            sudo apt install gh -y
        ;;
    "ubuntu")
        type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
            sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
            sudo apt update &&
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
    $upgrade 1>/dev/null
    ${installType} libsqlite3-dev liblzma-dev libbz2-dev libncurses5-dev libffi-dev libreadline-dev libssl-dev 1>/dev/null
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

installDocker() {

    command_exists docker &&
        echoContent green " ---> docker have been installed, nothing installed" && return

    command_exists docker || {
        pushd /tmp
        echoContent green " ---> installing docker"
        curl -fsSL https://get.docker.com -o get-docker.sh
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
    sudo gpasswd -a ${USER} docker
    sudo systemctl restart docker
    sudo chmod a+rw /var/run/docker.sock
}

uninstallDocker() {
    # Images, containers, volumes, and networks stored in /var/lib/docker/
    # aren't automatically removed when you uninstall Docker. If you want to
    # start with a clean installation, and prefer to clean up any existing data,
    # read the uninstall Docker Engine section.
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
    echoContent green "Images, containers, volumes, and networks stored in /var/lib/docker/ 
    aren't automatically removed when you uninstall Docker. If you want to start 
    with a clean installation, and prefer to clean up any existing data, 
    read the uninstall Docker Engine section."
}

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

installK8s() {

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

setupServerEnv() {
    installPythonByPyenv
    installGolang
    install_mysql
    installBatscore
    installNodejsByNvm
    installRedis
    installDocker
    # installk8s
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

setupDataIntensiveAppServerDependencies() {
    echo
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

dev_menu() {

    # 定义所有的安装命令
    commands=("installBatscore" "installCommonDevLib" "installDocker" "installGithub" "installGolang" "installK8s" "installNodejsByNvm" "installPkgBundle" "installPythonByPyenv" "installRclone" "installRedis" "install_hadoop" "install_java" "install_mysql" "install_scala" "install_zookeeper" "removePython" "setupDataIntensiveAppServerDependencies" "setupDisk" "setupServerEnv" "uninstallGithub" "uninstall_golang" "vpsSwissArmyKnife")

    # 创建一个复选框，让用户选择要执行的命令
    cmd=(dialog --separate-output --checklist "请选择要执行的命令：" 22 76 16)
    options=()
    for i in "${!commands[@]}"; do
        options+=("$i" "${commands[$i]}" off)
    done
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear

    # 执行用户选择的命令
    for choice in $choices; do
        case ${commands[$choice]} in
        installBatscore)
            echo "执行 installBatscore"
            installBatscore
            ;;
        installCommonDevLib)
            echo "执行 installCommonDevLib"
            installCommonDevLib
            ;;
        installDocker)
            echo "执行 installDocker"
            installDocker
            ;;
        installGithub)
            echo "执行 installGithub"
            installGithub
            ;;
        installGolang)
            echo "执行 installGolang"
            installGolang
            ;;
        installK8s)
            echo "执行 installK8s"
            installK8s
            ;;
        installNodejsByNvm)
            echo "执行 installNodejsByNvm"
            installNodejsByNvm
            ;;
        installPkgBundle)
            echo "执行 installPkgBundle"
            installPkgBundle
            ;;
        installPythonByPyenv)
            echo "执行 installPythonByPyenv"
            installPythonByPyenv
            ;;
        installRclone)
            echo "执行 installRclone"
            installRclone
            ;;
        installRedis)
            echo "执行 installRedis"
            installRedis
            ;;
        install_hadoop)
            echo "执行 install_hadoop"
            install_hadoop
            ;;
        install_java)
            echo "执行 install_java"
            install_java
            ;;
        install_mysql)
            echo "执行 install_mysql"
            install_mysql
            ;;
        install_scala)
            echo "执行 install_scala"
            install_scala
            ;;
        install_zookeeper)
            echo "执行 install_zookeeper"
            install_zookeeper
            ;;
        removePython)
            echo "执行 removePython"
            removePython
            ;;
        setupDataIntensiveAppServerDependencies)
            echo "执行 setupDataIntensiveAppServerDependencies"
            setupDataIntensiveAppServerDependencies
            ;;
        setupDisk)
            echo "执行 setupDisk"
            setupDisk
            ;;
        setupServerEnv)
            echo "执行 setupServerEnv"
            setupServerEnv
            ;;
        uninstallGithub)
            echo "执行 uninstallGithub"
            uninstallGithub
            ;;
        uninstall_golang)
            echo "执行 uninstall_golang"
            uninstall_golang
            ;;
        vpsSwissArmyKnife)
            echo "执行 vpsSwissArmyKnife"
            vpsSwissArmyKnife
            ;;
        esac
    done
}