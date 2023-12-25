#!/usr/bin/env bash
# -------------------------------------------------------------
# 检查系统
set -e

source basic_installer.sh
source common.sh
source dev_env.sh
source server_env.sh
export LANG=en_US.UTF-8

#js whiptail --title "Success" --msgbox "c" 10 60
# if [ `export|grep 'LC_ALL'|wc -l` = 0 ];then
#     if [ `grep "LC_ALL" /etc/profile|wc -l` = 0 ];then
#         echo "export LC_ALL='en_US.UTF-8'" >> /etc/profile
#     fi
# fi
# if [ `grep "alias ll" /etc/profile|wc -l` = 0 ];then
#     echo "alias ll='ls -alh'" >> /etc/profile
#     echo "alias sn='snapraid'" >> /etc/profile
# fi
# source /etc/profile

#-----------------functions--start------------------#
example() {
    #msgbox
    whiptail --title "Success" --msgbox "
" 10 60
    #yesno
    if (whiptail --title "Yes/No Box" --yesno "
" 10 60); then
        echo ""
    fi
    #password
    PASSWORD=$(whiptail --title "Password Box" --passwordbox "
Enter your password and choose Ok to continue.
                " 10 60 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        echo "Your password is:" $m
    fi

    #input form
    NAME=$(
        whiptail --title "
Free-form Input Box
" --inputbox "
What is your pet's name?
" 10 60
        Peter
        3>&1 1>&2 2>&3
    )

    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        echo ""
    else
        echo ""
    fi

    #processing
    apt -y install mailutils
}

# initialize global variable
# 在安装 install_zsh 后，需要再运行一次 init() 函数，以更新 shellProfile 变量

# 检查wget showProgress
checkWgetShowProgress() {
    if find /usr/bin /usr/sbin | grep -q -w wget && wget --help | grep -q show-progress; then
        wgetShowProgressStatus="--show-progress"
    fi
}

basic_menu() {
    if [ $L = "en" ]; then
        choices=$(whiptail --title "component options" --checklist \
            "Please selected which you want to install：" 20 78 15 \
            "1" "setup neovim" OFF \
            "2" "setup zsh" OFF \
            "3" "setup tmux" OFF \
            "4" "setup tons of packages by DPKG" OFF \
            "5" "setup ssh" \
            "6" "setup shell" \
            "7" "setup enhanced tools" \
            "8" "setup other basic tools" \
            "9" "setup all" \
            "10" "attach nfs" \
            3>&1 1>&2 2>&3)
    else
        choices=$(whiptail --title "安装选项" --checklist \
            "请选择你要安装的项目：" 20 78 15 \
            "1" "安装neovim" OFF \
            "2" "安装zsh" OFF \
            "3" "安装tmux" OFF \
            "4" "通过DPKG安装大量包" OFF \
            "5" "安装ssh" OFF \
            "6" "安装shell" OFF \
            "7" "安装增强工具" OFF \
            "8" "安装其他基础工具" OFF \
            "9" "安装所有" OFF \
            "10" "挂载 nfs" OFF \
            3>&1 1>&2 2>&3)
    fi

    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        IFS=" " read -r -a array <<<"$choices"
        for choice in "${array[@]}"; do
            case $choice in
            "\"1\"")
                setupNeovim
                # 在这里添加安装neovim的命令
                ;;
            "\"2\"")
                setupShell

                # 在这里添加安装zsh的命令
                ;;
            "\"3\"")
                setupTmux
                # 在这里添加安装tmux的命令
                ;;

            "\"4\"") # 在这里添加安装大量包的命令
                setupToolsByDPKG
                ;;

            "\"5\"")
                sshConfig
                ;;
            "\"6\"")
                setupShell
                ;;
            "\"7\"")
                installEnhancedTools
                ;;
            "\"8\"")
                installOtherBasicTools
                ;;
            "\"9\"")
                setupAll
                ;;
            "\"10\"")
                setupDisk
                ;;
            esac
        done
        main
    else
        echo "你取消了操作。"
    fi
}

server_menu() {
    echo
}

dev_menu() {

    # 定义所有的安装命令
    if [ $L = "en" ]; then
        choices=$(whiptail --title "component options" --checklist \
            "Please selected which you want to install：" 20 78 15 \
            "1" "install  Batscore" OFF \
            "2" "install CommonDevLib" OFF \
            "3" "install Docker" OFF \
            "4" "install Github" OFF \
            "5" "install Golang" OFF \
            "6" "install K8s" OFF \
            "7" "install NodejsByNvm" OFF \
            "8" "install PkgBundle" OFF \
            "9" "install PythonByPyenv" OFF \
            "10" "install Rclone" OFF \
            "11" "install Redis" OFF \
            "12" "install hadoop" OFF \
            "13" "install java" OFF \
            "14" "install mysql" OFF \
            "15" "install scala" OFF \
            "16" "install zookeeper" OFF \
            "17" "removePython" OFF \
            "18" "setupDisk" OFF \
            "19" "setupServerEnv" OFF \
            "20" "uninstall Github" OFF \
            "21" "uninstall golang" OFF \
            "22" "vpsSwissArmyKnife" OFF \
            3>&1 1>&2 2>&3)
    else
        choices=$(whiptail --title "安装选项" --checklist \
            "请选择你要安装的项目：" 20 78 15 \
            "1" "installBatscore" OFF \
            "2" "installCommonDevLib" OFF \
            "3" "installDocker" OFF \
            "4" "installGithub" OFF \
            "5" "installGolang" OFF \
            "6" "installK8s" OFF \
            "7" "installNodejsByNvm" OFF \
            "8" "installPkgBundle" OFF \
            "9" "installPythonByPyenv" OFF \
            "10" "installRclone" OFF \
            "11" "installRedis" OFF \
            "12" "install_hadoop" OFF \
            "13" "install_java" OFF \
            "14" "install_mysql" OFF \
            "15" "install_scala" OFF \
            "16" "install_zookeeper" OFF \
            "17" "removePython" OFF \
            "18" "setupDisk" OFF \
            "19" "setupServerEnv" OFF \
            "20" "uninstallGithub" OFF \
            "21" "uninstall_golang" OFF \
            "22" "vpsSwissArmyKnife" OFF \
            3>&1 1>&2 2>&3)
    fi

    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        IFS=" " read -r -a array <<<"$choices"
        for choice in "${array[@]}"; do
            case $choice in
            "\"1\"")
                installBatscore
                ;;
            "\"2\"")
                installCommonDevLib
                ;;
            "\"3\"")
                installDocker
                ;;
            "\"4\"")
                installGithub
                ;;
            "\"5\"")
                installGolang
                ;;
            "\"6\"")
                installK8s
                ;;
            "\"7\"")
                installNodejsByNvm
                ;;
            "\"8\"")
                installPkgBundle
                ;;
            "\"9\"")
                installPythonByPyenv
                ;;
            "\"10\"")
                installRclone
                ;;
            "\"11\"")
                installRedis
                ;;
            "\"12\"")
                install_hadoop
                ;;
            "\"13\"")
                install_java
                ;;
            "\"14\"")
                install_mysql
                ;;
            "\"15\"")
                install_scala
                ;;
            "\"16\"")
                install_zookeeper
                ;;
            "\"17\"")
                removePython
                ;;
            "\"18\"")
                setupDisk
                ;;
            "\"19\"")
                setupServerEnv
                ;;
            "\"20\"")
                uninstallGithub
                ;;
            "\"21\"")
                uninstall_golang
                ;;
            "\"22\"")
                vpsSwissArmyKnife
                ;;
            esac
        done
        main
    else
        echo "你取消了操作。"
    fi
}

main() {
    if [ $L = "en" ]; then
        OPTION=$(whiptail --title " PveTools   Version : 2.3.9 " --menu "
Github: https://github.com/ivanhao/pvetools
Please choose:" 25 100 15 \
            "a" "setup basic environment, including zsh, tmux, nvim, ssh, install tons of basic pkgs" \
            "b" "setup development environment, including github, programming language compiler, language server, etc." \
            "c" "setup server environment, including docker, k8s, redis/mysql database, etc." \
            3>&1 1>&2 2>&3)
    else
        OPTION=$(whiptail --title " PveTools   Version : 2.3.9 " --menu "
Github: https://github.com/ivanhao/pvetools
请选择相应的配置：" 25 60 15 \
            "a" "设置基本环境，包括zsh、tmux、nvim、ssh，安装大量基本软件包。" \
            "b" "设置开发环境，包括github、编程语言编译器、语言服务器等。" \
            "c" "设置服务器环境，包括docker、k8s、redis/mysql数据库等。" \
            3>&1 1>&2 2>&3)
    fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$OPTION" in
        a)
            basic_menu
            main
            ;;
        b)
            dev_menu
            main
            ;;
        c)
            server_menu
            main
            ;;
        L)
            if (whiptail --title "Yes/No Box" --yesno "Change Language?
修改语言？" 10 60); then
                if [ $L = "zh" ]; then
                    L="en"
                else
                    L="zh"
                fi
                main
                #main $L
            fi
            ;;
        exit | quit | q)
            exit
            ;;
        esac
    else
        exit
    fi
}

if (whiptail --title "Language" --yes-button "中文" --no-button "English" --yesno "Choose Language:
选择语言：" 10 60); then
    L="zh"
else
    L="en"
fi
main
