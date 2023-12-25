#!/usr/bin/env bash
printHeader() {

    echo ""
    echo " ========================================================= "
    echo " \            Linux init.sh linux developing environment deploymnt script V 1.1             / "
    echo " ========================================================= "
    echo " # author：RussellLoveCoding
echo " # https://github.com/RussellLoveCoding                    "
    echo -e "\n"
}

# feature:
# 0. Idempotent. no side effect.
# 1. auto detect os system, cpu arch and choose the right version of software
# 2. auto detect shell profile
# 3. let you choose if encounter options.
# 4. you can remove installed packages using this script.

# print message $2 with specifid color $1

################# Helper Function  #################

echoContent() {
    local color=$1
    local content=$2
    case $color in
    "red") echo -e "\033[31m${content}\033[0m" ;;
    "green") echo -e "\033[32m${content}\033[0m" ;;
    "yellow") echo -e "\033[33m${content}\033[0m" ;;
    "blue") echo -e "\033[34m${content}\033[0m" ;;
    "purple") echo -e "\033[35m${content}\033[0m" ;;
    "skyblue") echo -e "\033[36m${content}\033[0m" ;;
    "white") echo -e "\033[37m${content}\033[0m" ;;
    *) echo "${content}" ;;
    esac
}
# echoContent() {
#     case $1 in
#     # 红色
#     "red")
#         # shellcheck disable=SC2154
#         echo -e "\033[31m${printN}$2 \033[0m"
#         ;;
#         # 天蓝色
#     "skyBlue")
#         echo -e "\033[1;36m${printN}$2 \033[0m"
#         ;;
#         # 绿色
#     "green")
#         echo -e "\033[32m${printN}$2 \033[0m"
#         ;;
#         # 白色
#     "white")
#         echo -e "\033[37m${printN}$2 \033[0m"
#         ;;
#     "magenta")
#         echo -e "\033[31m${printN}$2 \033[0m"
#         ;;
#         # 黄色
#     "yellow")
#         echo -e "\033[33m${printN}$2 \033[0m"
#         ;;
#     esac
# }

command_exists() {
    command -v "$@" 1>/dev/null 2>&1
}

execute_with_timeout() {
    local cmd=$1
    local timeout_seconds=$2
    local error_message=$3

    timeout $timeout_seconds sh -c "$cmd"
    if [ $? -eq 124 ]; then
        echo "$error_message"
        exit 1
    fi
}

checkAndAddLine() {
    local file=$1
    local line=$2

    # 检查行是否存在
    if grep -qF "$line" $file; then
        # 如果存在并且被注释，取消注释

        # 使用printf '%s\n' "$line"来确保$line中的所有字符都被视为字面字符，而不是正则表达式的一部分S
        # -e 它允许你使用基本的正则表达式语法，而不是扩展的正则表达式语法。在基本的正则表达式语法中，你需要使用\来转义特殊字符
        sed -i -e "s~# *$(printf '%s\n' "$line")~$(printf '%s\n' "$line")~g" "$file"
    else
        # 该行不存在，追加它
        echo "$line" >>"$file"
    fi
}

unalias_list() {
    if alias | \grep -Eq '^grep'; then
        unalias grep
    fi

    if alias | \grep -Eq '^cp'; then
        unalias cp
    fi

    if alias | \grep -Eq '^rm'; then
        unalias rm
    fi

    if alias | \grep -Eq '^mv'; then
        unalias mv
    fi
}

init() {

    test=0
    test=$1
    # installation total progress
    totalProgress=1

    # path definition
    globalInstallDir='/usr/local'
    localInstallDir="$HOME/opt"
    errLogFile='/tmp/modern_linux_init_error.log'
    execLogFile='/tmp/modern_linux_init_exec.log'
    modernEnvPath="/tmp/modern-linux-env-init"
    modernEnvHomeDir="${modernEnvPath}/homedir"
    containerDir="${modernEnvPath}/containers"
    

    # command redefinition, in case alias
    installType='sudo apt-get -y install'
    removeType='sudo apt-get -y remove'
    upgrade="sudo apt-get -y update"

    optdir="$HOME/opt"
    sed="\sed"
    rm="\rm"
    usrlocal='/usr/local'
    ip="\ip"

    # detect architecture and os type
    os=$(uname -s | tr '[:upper:]' '[:lower:]')
    arch=$(uname -m)

    # detect distribution
    distro=$(cat /etc/*-release | grep '^ID=' | cut -d'=' -f2)
    case "$distro" in
    "centos")
        release="centos"
        installType='sudo yum -y install'
        removeType='sudo yum -y remove'
        upgrade="sudo yum update -y --skip-broken"
        ;;
    "debian")
        release="debian"
        installType='sudo apt-get -y install'
        upgrade="sudo apt-get update"
        removeType='sudo apt-get -y autoremove'
        ;;
    "ubuntu")
        release="ubuntu"
        installType='sudo apt-get -y install'
        upgrade="sudo apt-get update"
        removeType='sudo apt-get -y autoremove'
        ;;
    *)
        echo "不支持的系统"
        exit 1
        ;;
    esac

    # detect shell shell profile
    if [ -n "$($SHELL -c 'echo $ZSH_VERSION')" ]; then
        shellProfile="$HOME/.zshrc"
    elif [ -n "$($SHELL -c 'echo $BASH_VERSION')" ]; then
        shellProfile="$HOME/.bashrc"
    elif [ -n "$($SHELL -c 'echo $FISH_VERSION')" ]; then
        shell="fish"
        if [ -d "$XDG_CONFIG_HOME" ]; then
            shellProfile="$XDG_CONFIG_HOME/fish/config.fish"
        else
            shellProfile="$HOME/.config/fish/config.fish"
        fi
    fi

    # fetch necessary configuration file.
    [ -d $modernEnvPath ] || {
        echoContent green " --> fetching necessary configuration file from github"
        git clone https://github.com/RussellLoveCoding/modern-linux-env-init.git $modernEnvPath 1>/dev/null 2>&1
    }
}

# according to config.yml file, generate .zshrc file correctly, including pyenv, nvm, fzf and so on.
# such as pyenv
# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# if command -v pyenv 1>/dev/null 2>&1; then
#     eval "$(pyenv init -)"
# fi

genShellProfile() {
    for pkg in pyenv; do
        cat $pkg.template >>$shellProfile

        #
    done
}

check_network() {
    if ! curl -s -o /dev/null -w "%{http_code}" --head --request GET https://www.baidu.com/  --max-time 3 | grep -qE "200|301"; then
        echoContent red "baidu.com is not reachable"
        echoContent red "please check your network, nothing installed, exited"
        exit 1
    fi

    if ! curl -s -o /dev/null -w "%{http_code}" --head --request GET https://github.com/ --max-time 3| grep -qE "200|301"; then
        echoCOntent red "github.com is not reachable"
        echoCOntent red "please check your network, nothing installed, exited"
        exit 1
    fi

    if ! curl -s -o /dev/null -w "%{http_code}" --head --request GET https://google.com/ --max-time 3 | grep -qE "200|301"; then
        echoContent red "google.com is not reachable"
        echoContent red "please check your network"
        echoContent red "you maybe encounter some network timeout during the course of setup"
    fi

}

unalias_list
init
check_network
if ! command_exists  dialog; then
    $installType dialog 1>/dev/null
fi

if ! command_exists  whiptail; then
    $installType whiptail 1>/dev/null
fi
