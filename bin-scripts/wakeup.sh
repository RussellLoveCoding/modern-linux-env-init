#!/bin/bash

# 定义主机列表，每个主机的格式为 "主机名 MAC地址"
HOSTS=(
    "pve 0a:e0:af:f2:27:f6"
    "home-server 68:da:73:a6:1e:00"
)

# 检测操作系统类型
OS=$(uname)

# 根据操作系统类型安装必要的工具
if [[ $OS == "Linux" ]]; then
    if [[ -n $(command -v apt) ]]; then
        if [[ -z $(command -v wakeonlan) ]]; then
            echo "installing wakeup tool ... "
            sudo apt update && sudo apt install -y wakeonlan 1>/dev/null 2>&1
        fi
    elif [[ -n $(command -v yum) ]]; then
        if [[ -z $(command -v wakeonlan) ]]; then
            echo "installing wakeup tool ... "
            sudo yum install -y wakeonlan 1>/dev/null 2>&1
        fi
    elif [[ -n $(command -v opkg) ]]; then
        if [[ -z $(command -v etherwake) ]]; then
            echo "installing wakeup tool ... "
            opkg update && opkg install etherwake 1>/dev/null 2>&1
        fi
    fi
fi

# 列出所有主机并等待用户选择
echo "请选择要唤醒的主机："
for i in "${!HOSTS[@]}"; do
    echo "$((i+1)). ${HOSTS[$i]%% *}"
done

read -p "请输入主机序号： " CHOICE

# 获取用户选择的主机的MAC地址
MAC=${HOSTS[$((CHOICE-1))]##* }

# 发送魔术包唤醒主机
if [[ $OS == "Linux" ]]; then
    if [[ -n $(command -v wakeonlan) ]]; then
        wakeonlan $MAC
    elif [[ -n $(command -v etherwake) ]]; then
        etherwake $MAC
    fi
fi

echo "已向主机 ${HOSTS[$((CHOICE-1))]%% *} 发送魔术包。"
