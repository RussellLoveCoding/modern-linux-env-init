#!/usr/bin/env bash
set -e
source common.sh

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

installPVE() {
    sed -rin 's~(.*)~# \1~g;' /etc/apt/sources.list.d/pve-enterprise.list
    echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" >> /etc/apt/sources.list.d/pve-enterprise.list
    apt update --allow-insecure-repositories --allow-unauthenticated
    apt-get install vim lrzsz unzip net-tools curl screen uuid-runtime git -y 
    apt dist-upgrade -y
}
installKVM() {
    # 安装所需的软件包：
    $installType bridge-utils cpu-checker libvirt-clients libvirt-daemon qemu qemu-kvm 1>/dev/null
    # 运行 kvm-ok 命令并保存输出
    output=$(kvm-ok)

    # 检查输出是否包含 "KVM acceleration can be used"
    if echo "$output" | grep -q "KVM acceleration can be used"; then
        echo "支持 KVM 虚拟化"
    else
        echo "不支持 KVM 虚拟化"
    fi

    # Install OpenStack 安装 OpenStack
    sudo snap install openstack
    # Install dependencies 安装依赖项
    sunbeam prepare-node-script | bash -x && newgrp snap_daemon
    # Bootstrap the cloud 引导云
    sunbeam cluster bootstrap --accept-defaults
}

diable_bunch_of_server_stuff() {
    sudo snap disable microk8s
    sudo snap disable nextcloud
    sudo snap disable wekan
    sudo snap disable kata-containers
    sudo snap disable docker
    sudo snap disable canonical-livepatch
    sudo snap disable rocketchat-server
    sudo snap disable mosquitto
    sudo snap disable etcd
    sudo snap disable powershell
    sudo snap disable sabnzbd
    sudo snap disable wormhole
    sudo snap disable aws-cli
    sudo snap disable google-cloud-sdk
    sudo snap disable slcli
    sudo snap disable doctl
    sudo snap disable conjure-up
    sudo snap disable postgresq110
    sudo snap disable heroku
    sudo snap disable keepalived
    sudo snap disable prometheus
    sudo snap disable juju
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

server_menu() {

    commands=("installKVM" "installPVE" "installDocker" "installK8s" "installRedis" "install_hadoop" "install_mysql" "install_mysql")

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
            installKVM)
                installKVM
                ;;
            installPVE)
                installPVE
                ;;
            installDocker)
                installDocker
                ;;
            installK8s)
                installK8s
                ;;
            installRedis)
                installRedis
                ;;
            install_hadoop)
                install_hadoop
                ;;
            install_mysql)
                install_mysql
                ;;
            install_zookeeper)
                install_zookeeper
                ;;
        esac
    done

}
