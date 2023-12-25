#!/bin/bash
set -e
source common.sh


traceroute() {
    # bash <(curl -sL bash.icu/speedtest)
    # bash <(curl -Lso- https://bench.im/hyperspeed)
    bash <(curl -Lso- https://www.infski.com/files/superspeed.sh)

}

initDir() {
    [ ! -d $containerDir ] && mkdir -p $containerDir
}

deployXrayNode() {
    wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
}

deployVaultwarden() {
    if [ ! -f $containerDir/vaultwarden/docker-compose.yml ]; then

    else 

    fi
}
