#!/usr/bin/env bash
# -------------------------------------------------------------
# 检查系统
set -e 

source basic-installer.sh  common.sh  dev-env.sh    network-config.sh  pkgs
source common.sh
source ./pkgs
export LANG=en_US.UTF-8

# initialize global variable
# 在安装 install_zsh 后，需要再运行一次 init() 函数，以更新 shellProfile 变量


# 检查wget showProgress
checkWgetShowProgress() {
    if find /usr/bin /usr/sbin | grep -q -w wget && wget --help | grep -q show-progress; then
        wgetShowProgressStatus="--show-progress"
    fi
}

setupSepcificTool() {
    echoContent red "==================== BASIC TOOLS ======================="
    echoContent yellow "1. setup ohmyzsh"
    echoContent yellow "2. setup neovim"
    echoContent yellow "3. setup tmux"
    echoContent red "==================== DEV TOOLS ======================="
    echoContent yellow "4. install nodejs by nvm"
    echoContent yellow "5. setup basic tools"

    read -r -p "请输入要安装的工具名称:" toolName
    case ${toolName} in
    1)
        setupShell
        ;;
    2)
        setupNeovim
        ;;
    3)
        setupTmux
        ;;
    4)
        installNodejsByNvm
        ;;
    esac
}

# 主菜单
menu() {

    echoContent red "\n=============================================================="
    echoContent green "作者：russel"
    echoContent green "当前版本：v0.1"
    echoContent green "Github：https://github.com/RussellLoveCoding"
    echoContent green "描述: Linux 初始化\n"
    checkWgetShowProgress
    echoContent red "=============================================================="
    echoContent yellow "1. setup shell"
    echoContent yellow "2. setup basic tools"
    echoContent yellow "3. setup server env"
    echoContent yellow "4. setup programmming language"
    echoContent yellow "5. setup disk"
    echoContent yellow "6. setup network"
    echoContent yellow "7. setup data intensive app server dependencies: including hadoop, zookeeper"
    echoContent yellow "8. setup specific tool"
    echoContent red "=============================================================="

    read -r -p "请选择:" selectInstallType
    case ${selectInstallType} in
    1)
        setupShell
        ;;
    2)
        setupBasicTools
        ;;
    3)
        setupServerEnv
        ;;
    4)
        setupProgLang
        ;;
    5)
        setupDisk
        ;;
    6)
        setupNetwork
        ;;
    7)
        setupDataIntensiveAppServerDependencies
        ;;
    8)
        setupSepcificTool
        ;;
    esac
}
init
menu