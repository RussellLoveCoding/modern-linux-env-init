#!/bin/bash
set -e
source common.sh

traceroute() {
    # bash <(curl -sL bash.icu/speedtest)
    # bash <(curl -Lso- https://bench.im/hyperspeed)
    bash <(curl -Lso- https://www.infski.com/files/superspeed.sh)

}

serverContainerDir="$HOME/containers"
srcContainerDir="${modernEnvPath}/containers"

initDir() {
    [ ! -d $serverContainerDir ] && mkdir -p $serverContainerDir
}

deployXrayNode() {
    wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
}

deployPortainer() {
    su -
    docker volume create portainer_data
    docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
    # login via https://localhost:9443
}

deployVaultwarden() {
    if [ -d $serverContainerDir/vaultwarden ]; then
        echoContent red "  ------------> $serverContainerDir/vaultwarden directory already exists, nothing installed"
        return
    fi
    mkdir -p $serverContainerDir/vaultwarden
    cp $srcContainerDir/vaultwarden.yml $serverContainerDir/vaultwarden/docker-compose.yml
    cd $serverContainerDir/vaultwarden
    docker compose up -d
}

deployCalibreWeb() {
    if [ -d $serverContainerDir/calibre ]; then
        echoContent red "  ------------> $serverContainerDir/vaultwarden directory already exists, nothing installed"
        return
    fi
    mkdir -p $serverContainerDir/calibre
    cp $srcContainerDir/calibre-web.yml $serverContainerDir/calibre/docker-compose.yml
    cd $serverContainerDir/calibre
    docker compose up -d
}

# http://<host>:8123
deployHomeAssistant() {

    if [ -d $serverContainerDir/home-assistant ]; then
        echoContent red "Home assistant already existed"
        return
    fi
    mkdir -p $serverContainerDir/home-assistant

    docker run -d \
        --name homeassistant \
        --privileged \
        --restart=unless-stopped \
        -e TZ=MY_TIME_ZONE \
        -v $serverContainerDir/home-assistant:/config \
        -v /run/dbus:/run/dbus:ro \
        -p 10002:80 \
        ghcr.io/home-assistant/home-assistant:stable
}

deployStorageService() {
    # joplin server 同步比 webdav 速度快十倍以上
    echo
}

deployJellyfin() {
    if [ -d $serverContainerDir/jellyfin ]; then
        echoContent red "jellyfin already existed"
    fi
    mkdir -p $serverContainerDir/jellyfin
    cp $srcContainerDir/jellyfin.yml $serverContainerDir/jellyfin/docker-compose.yml
    cd $serverContainerDir/calibre
    docker compose up -d
}

deployCodeServer() {
    curl -sSL https://raw.githubusercontent.com/coder/code-server/main/install.sh | bash
}

# 统一登陆平台
deployAuthentication() {
    echoContent green "not implemented yet"
}