#!/usr/bin/env bash
#set -x
set -e
source common.sh

# 超详细教程-J4125小主机从到手到安装PVE，iStoreOS作为主路由全过程小记(使用虚拟化)
# 参考 https://blog.welain.com/archives/183/
config_static_ip_address_for_os_router() {
    echo
}

disable_docker() {
    /etc/init.d/dockerd
}

install_qemu_agent() {
    # 安装
    opkg update
    opkg install qemu-ga

    # 设置脚本权限
    chmod +x /etc/init.d/qemu-ga

    # 启用服务
    /etc/init.d/qemu-ga enable

    # 重启
    reboot
}

# 防火墙在上游网段开放端口
step1_allow_http_s_ssh_access_on_wan() {

    # 在局域网内开放所有端口
    echoContent skyBlue "
请添加如下内容到 /etc/config/firewall
config rule
        option name 'Allow-all-port-from-local-subnet'
        option src 'wan'
        option proto 'tcp udp'
        option dest_port '0-65535'
        option target 'ACCEPT'
        option family 'any'
        option src_ip '192.168.0.0/16'
"
    echoContent skyBlue "同时确保, /etc/config/uhttpd 中 config uhttpd 'main' 中的 'option listen_http ' 和 'option listen_https' 监听所有ip地址，也就是 0.0.0.0:80, 0.0.0.0:443"
    echoContent skyBlue "添加完成后，执行以下命令重启服务 "
    # 这里不知道是192.168.100.1 跟上游的 istoreos 冲突还是 没有重启 network, 单
    # 纯改上面的 firewall 规则不行, 要下面的都改了才行
    echoContent skyBlue "/etc/init.d/firewall restart && /etc/init.d/uhttpd restart && /etc/init.d/network restart"
}

step1_dot_2_config_static_ip_address() {
    echoContent green "here is the correct /etc/config/network example to set static ip address and new subnet"
    network_conf_example="
config interface 'wan'
	option device 'eth0'
	option proto 'static'
	option ipaddr '192.168.100.100'
	option netmask '255.255.255.0'

config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option ipaddr '192.168.2.1'
	option netmask '255.255.255.0'
	option ip6assign '60'
"

    # wan 口是接上游路由的联网的口 eth1，lan口是 eth0(pve虚拟的网口), eth2, eth3
    # (直通的物理网口),  接口 config interface 'lan' 指新的子网网段
    echoContent green "cat /etc/config/network
config interface 'loopback'
        option device 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd95:8014:cb26::/48'

config interface 'wan'
        option proto 'dhcp'
        option device 'eth1'

config interface 'wan6'
        option device 'eth0'
        option proto 'dhcpv6'

config device
        option name 'br-lan'
        option type 'bridge'
        list ports 'eth2'
        list ports 'eth3'
        list ports 'eth0'

config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '192.168.2.1'
        option netmask '255.255.255.0'
        option ip6assign '60'    
"
}

step2_setup_ssh() {
    echo "check out ip address of you router os by looking up console on pve web interafce",
    echo
    echo "then execute the following command to add your public key to router os, the default password for iStoreOS is \"password\""
    echo
    echo "ssh-copy-id root@remote_host"
}

step3_config_new_subnetwork_address() {

    # 定位到如下内容让用户修改
    echoContent skyBlue "请输入你想要更改的子网段地址，格式为: 192.168.xxx.1, 其中 xxx 为其中一个子网段的地址，值从 2- 254 之间"
    read subnet_addr
    sed -rin "s~192.168.100.1~$subnet_addr~;" /etc/config/network

    echoContent skyBlue "已经修改配置文件, 如下"
    \grep "config interface 'lan'" -A 6 /etc/config/network

    echoContent skyBlue "正在重启网络..."
    /etc/init.d/network restart
    status=$?
    # 根据状态码输出相应信息
    if [ $status -eq 0 ]; then
        echoContent green "网络重启成功。"
    else
        echoContent red "网络重启失败，状态码：$status"
    fi

}

step4_install_apps() {
    echo
}
# 安装梯子工具
install_passwall() {
    cd /tmp
    base_url="https://github.com/bcseputetto/Are-u-ok/releases/latest"
    download_page=$(wget -qO- $base_url)
    passwall_pkg=$(echo "$download_page" | \grep -Eio '>passwall[^0-9][^<]+x86_64[^<]+run' | sed -rn 's~>~~p' | sort | uniq)
    passwall2_pkg=$(echo "$download_page" | \grep -Eio '>passwall2[^<]+x86_64[^<]+run' | sed -rn 's~>~~p' | sort | uniq)

    # 下载软件包
    dlink_base="https://github.com/bcseputetto/Are-u-ok/releases/download/iStoreOS/"
    wget "${dlink_base}${passwall2_pkg}"
    wget "${dlink_base}${passwall_pkg}"
    opkg update
    sh "$passwall2_pkg"
    sh "$passwall_pkg"
    rm "$passwall2_pkg"
    rm "$passwall_pkg"
}

install_passwall() {
    repo="bcseputetto/Are-u-ok"
    api_url="https://api.github.com/repos/$repo/releases/latest"
    # 获取最新发布的资产 URL
    rm /tmp/*run
    asset_url=$(curl -s $api_url | grep "browser_download_url" | cut -d '"' -f 4 | \grep -Ei '.*passwall.*x86_64.*\.run$')
    sh /tmp/*run

    echo "going to download the following package"
    echo "$asset_url"

    # 下载资产
    for url in $asset_url; do
        wget -P /tmp "$url"
    done
}

install_unblock_netease_music() {
    repo="UnblockNeteaseMusic/luci-app-unblockneteasemusic"
    api_url="https://api.github.com/repos/$repo/releases/latest"

    # 获取最新发布的资产 URL
    asset_url=$(curl -s $api_url | grep "browser_download_url" | cut -d '"' -f 4 | \grep -E '.*\.ipk$')

    echo "going to download the following package"
    echo "$asset_url"

    # 下载资产
    rm /tmp/*ipk

    for url in $asset_url; do
        wget -P /tmp "$url"
    done

    opkg install /tmp/*ipk
}

# 网络分流 英文： 
network_traffic_diversion() {
    # 大流量域名

    # onedrive, 
    large_flow_domains='
files.1drv.com
storage.live.com
'

    # direct domains
    direct_domains='
zaobao.com
zaobao.com.sg
'

    cn_cdn_domains='
    '
}
