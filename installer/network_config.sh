#!/usr/bin/env bash

setupNetwork() {

    installProxyServer() {
        wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
    }

    install_proxychains() {
        pushd /tmp
        git clone https://github.com/rofl0r/proxychains-ng.git
        cd proxychains-ng
        make -j
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
