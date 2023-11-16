#!/bin/bash
set -e -x
XRAY_SHARE_DIR="/usr/local/share/xray"
XRAY_BIN_DIR="/usr/local/xray"

setup() {
  # 准备, 下载好 geoip, geosite 数据库, 新建对应的目录和日志文件
  su -
  test -d $XRAY_SHARE_DIR || mkdir $XRAY_SHARE_DIR
  test -e $XRAY_SHARE_DIR/error.log || touch $XRAY_SHARE_DIR/error.log
  test -e $XRAY_SHARE_DIR/access.log || touch $XRAY_SHARE_DIR/access.log

  # 下面的命令总说有问题, 也不懂为啥
  sudo curl -oL /usr/local/share/xray/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
  sudo curl -oL /usr/local/share/xray/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat

  #sudo wget -O /usr/local/share/xray/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
  #sudo wget -O /usr/local/share/xray/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat

  # GID 透明代理
  # 第一条命令：
  # 改变最大打开文件数，只对当前终端有效，每次启动 Xray 前都要运行，该命令是设置客户端的最大文件打开数
  # 第二条命令：
  # 以 uid 为 0，gid 不为 0 的用户来运行 Xray 客户端，后面加&代表放在后台运行
  # 检查最大文件打开数是否设置成功

  # 新建用户 xray_tproxy 以 利用 uid=0, gid!= 0 的原理避免回环流量，参考https://xtls.github.io/document/level-2/iptables_gid.html#%E6%80%9D%E8%B7%AF
  grep -qw xray_tproxy /etc/passwd || echo "xray_tproxy:x:0:23333:::" >>/etc/passwd
  ulimit -SHn 1000000
  sudo -u xray_tproxy xray -c $XRAY_BIN_DIR/transparent_proxy_config.json &

  ip rule add fwmark 1 table 100
  ip route add local 0.0.0.0/0 dev lo table 100

  # 获取本机 IP 地址并生成 iptables 规则
  IP_RULES=$(ip address | grep -w inet | awk '{print $2}' | sed -rn 's~(.*)~ip daddr \1 return ~p')

  # 将匹配到的行替换为 iptables 规则
  cp ntf.conf.ori ntf.conf
  sed -i '/ipv4_subnet_where_the_gateway_is_located/{
    r /dev/stdin
    d
  }' $XRAY_BIN_DIR/ntf.conf <<<"$IP_RULES"

  # 执行命令，
  $XRAY_BIN_DIR/ntf.conf
}

ping() {
  echo ping
}

# 最后执行这个提示错误，貌似是系统内核问题，日了狗了，用iptables 又因为系统的 iptables 是假的 iptables，用nftalbe 包装的。
# what does the follow output mean after I executed the selected code? output:
# /usr/local/xray/ntf.conf:3:16-19: Error: No such file or directory; did you mean table ‘xray’ in family ip? flush table ip xray
# ^^^^ /usr/local/xray/ntf.conf:31:25-49: Error: Could not process rule: No such file or directory
# ip protocol tcp tproxy to 127.0.0.1:12345 meta mark set 1
#           ^^^^^^^^^^^^^^^^^^^^^^^^^ /usr/local/xray/ntf.conf:32:25-49: Error: Could not process rule: No such file or directory
#           ip protocol udp tproxy to 127.0.0.1:12345 meta mark set 1

start_tproxy() {
  sudo ip rule add fwmark 1 table 100
  sudo ip route add local 0.0.0.0/0 dev lo table 100
  ulimit -SHn 1000000
  sudo -u xray_tproxy xray -c $XRAY_BIN_DIR/transparent_proxy_config.json &
  sudo $XRAY_BIN_DIR/ntf.conf
}

# 为什么不用 v2raya，而是自己手动处理
# 因为自己搭建的节点采用 reality 协议，在 v2raya 导入后测试 http 连接总是 `NOT STABLE`
# 网上搜到说 "不支持 alterId>0 的 VMESS ", 但我的是 vless 协议，所以就只能手动了。
# 而 tproxy 又太复杂
tun2socks() {
  #variables

  # vps ip
  xray_ip=34.96.181.156
  # 默认网关
  def_gate=192.168.1.1

  # 使用 ip 命令创建一个名为 tun0 的虚拟网络接口，并将其配置为 VPN 连接。它还将
  # 为该接口添加一个 IPv4 地址（10.0.0.1/24）和一个 IPv6 地址 （fdfe:dcba:9876::1/125）。
  ip tuntap add dev tun0 mode tun user tun2socks
  ip addr add 10.0.0.1/24 dev tun0
  ip addr add fdfe:dcba:9876::1/125 dev tun0

  # 将 VPN 连接的远程 IP 地址添加到路由表中，以便将流量路由到该地址。
  ip route add $xray_ip via $def_gate
  ip link set tun0 up
  ip -6 link set tun0 up
  ip route add default dev tun0
  ip -6 route add default dev tun0
  chmod +x tun2socks

  # 启动 xray 程序，该程序将处理 VPN 流量。
  xray -c config.json >/dev/null &

  # 等待 5 秒钟，以确保 VPN 连接已经建立。
  sleep 5

  # 启动 tun2socks 程序，该程序将 VPN 流量路由到本地 SOCKS5 代理。
  ./tun2socks -device tun://tun0 -proxy socks5://127.0.0.1:10808 # you can define the local socks5 port here 10808 is the default

  # 删除创建的虚拟网络接口和路由表。
  ip tuntap del dev tun0 mode tun
  ip route del $xray_ip via $def_gate
}

# Check if the function exists (bash specific)
if declare -f "$1" >/dev/null; then
  # call arguments verbatim
  "$@"
else
  # Show a helpful error
  echo "'$1' is not a known function name" >&2
  exit 1
fi
