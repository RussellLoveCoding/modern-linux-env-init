#!/usr/bin/bash
# set -x
set -e
source ./windows_apps.sh

command_exists() {
    command -v "$@" 1>/dev/null 2>&1
}


guide() {
    echo "
本程序将引导你以尽可能少的人工干预的方式去初始化一台全能 windows. 过程中可能会遇到一些挑战, 如网络问题, 无法全程自动化, 需要手动处理少许问题.

网络环境需要科学网络.

0. 升级 windows 到最新版本, 让他安装所有最新驱动.
1. 登录账户, 同步 windows 偏好设置
2. 将 windows 升级到专业版. 路径是: [设置] -> [系统] -> [激活], 升级到专业版, 重启升级后使用某宝购买的激活码激活
3. 打开虚拟机功能(如果听不懂的, 跳过), 安装 openssh 功能(听不懂, 跳过)
4. 应用同步: 在 windows_apps.sh 注释掉不需要的 app 或者 添加需要的 app 对应的 winget 的 appid
    4.1. 在 msstore 安装 winget, 并且配置好 winget settinsg 
    4.2. 运行本脚本 一键安装所有应用, 有些需要手动的, 则请下载对应安装包手动安装
    4.3. 运行本脚本 恢复应用配置, 对于不能恢复的, 请手动恢复, 如遇到问题, 请手动重新安装应用.
        - [ ] 添加好环境变量.配置好软件.恢复好软件配置. 恢复好系统配置.
          - [ ] 将绿色软件或者便携版的软件加入到快速启动中. 这些软件全部创建快捷方式, 拷贝到 Windows 启动菜单 `C:\Users\abc\AppData\Roaming\Microsoft\Windows\Start Menu\Programs` 中, 然后每一个快捷方式都 逐个添加到 Utools 应用中, 方法是选中文件后按 鼠标中键 打开超级面板,并添加到 `加入文件启动`.  `winget settings` 中便携包的快捷方式位于 `C:\Program Files\WinGet\Links` 目录下, 如果不是, 请通过 everything 搜索.
          - [ ] 对于软件数据在 appdata/roaming 要将解压后直接覆盖. 
          - [ ] 对应用逐个打开登录账号,进行账户同步, 部分如 potplayer 则需要手动导入备份配置.
5. 数据同步: 通过 Onedrive 或者 百度网盘 等工具 将恢复数据, 并且使用 Goodsync 对文件夹 diff 以下, 确保没问题
6. 进一步调试适配电脑
    9.1 如 打开 火绒->工具箱->启动项管理 禁止/删除 相关启动项. 配置好右键菜单, 删除掉部分右键菜单,简化它.
    9.2 打开 ccleaner 清理好无效的注册表,(注意要在修复前先点击备份,防止出问题能回滚) 并清理好安装目录下无效的文件.如不懂可跳过.
    9.3 通过火绒或者 ccleaner 清理垃圾
"

}

# 检查安装包的域名是否有伪造, 人肉检查
check_winget_package_domain() {


    for group in "${apps_groups[@]}"; do
        echo "======================"
        echo "Group: $group"
        eval "apps=(\"\${${group}[@]}\")"
        echo '请检查相关URL的域名是否有伪造'
        for appid in "${apps[@]}"; do

            # Collect unique subdirs
            echo '-------'
            echo "APPID: $appid, 域名列表:"
            winget show --id "$appid" --exact --source winget | \grep -Eoi 'https://[a-zA-Z0-9.-]+' | sort | uniq | sed -rn 's~(.*)~    - \1~g;/.*/p'
            echo
        done
        echo
    done

}

# 在cygwin中 使用 winget 前，先给 cygwin 安装一些必要的软件
install_dev_toolsets() {

    # 支持中文
    tee -a $HOME/.bashrc >/dev/null <<EOT
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
EOT

    # cygwin rsync 安装
    # curl -O https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
    # install apt-cyg /bin
    # chmod +x /bin/apt-cyg

    # echo '打开cygwin的安装文件，继续安装两个包: lynx, wget, libcurl, curl 等等 ，安装好以后, 将 cygwin 的 bin 目录添加到系统的环境变量 PATH 中'

    # 手动安装打开 cygwin 的 gui 安装两个包
    # 建议用 GUI 一次性装完所有的包, 用 apt-cyg 安装会提示各种缺库.
    # lynx, wget, curl, tmux. zsh, 用 apt-cyg 装会提示缺库，我不知道应该装哪些库.
    # 这里路径不能加双引号, 软件源url也是,否则 会有路径错误的问题
    # 下面这里在 bash 下执行是可以的, 在 zsh 会有问题
    INSTALL='/cygdrive/d/Program_Files/bin/cygwin-setup  --no-admin --quiet-mode --no-shortcuts --root C:\cygwin64 --local-package-dir C:\cygwin64\packages --site http://mirrors.aliyun.com/cygwin/  --packages '
    REMOVE='cygwin-setup --no-admin --quiet-mode --no-shortcuts --root C:\cygwin64 --local-package-dir C:\cygwin64\packages  --site http://mirrors.aliyun.com/cygwin/ --remove-packages '
    UPGRADE='cygwin-setup --no-admin --quiet-mode --no-shortcuts --root C:\cygwin64 --local-package-dir C:\cygwin64\packages  --site http://mirrors.aliyun.com/cygwin/ --upgrade-also  '
    
    # 但是下面这两句的路径需要加上 双引号, 感觉这是因为 linux 和 windows 的不一样:
    # cygwin-setup.exe --no-admin --quiet-mode --no-shortcuts --root "C:\cygwin64" --site "http://mirrors.aliyun.com/cygwin/" --local-package-dir "C:\cygwin64\packages" --packages 
    # cygwin-setup.exe --no-admin --quiet-mode --no-shortcuts --root "C:\cygwin64" --site "http://mirrors.aliyun.com/cygwin/" --local-package-dir "C:\cygwin64\packages" --remove-packages 
    # cygwin-setup.exe --no-admin --quiet-mode --no-shortcuts --root "C:\cygwin64" --site "http://mirrors.aliyun.com/cygwin/" --local-package-dir "C:\cygwin64\packages" --packages aria2,bash-completion,colordiff,curl,dialog,git,httpie,jq,unziplynx,p7zip,ranger,rsync,the_silver_searcher,tmux,tree,vim,wget,zsh,btop

    packages_to_install="libiconv,libiconv-devel,zip,aria2,bash-completion,colordiff,curl,dialog,git,httpie,jq,unzip,lynx,p7zip,ranger,rsync,the_silver_searcher,tmux,tree,vim,wget,zsh,btop"
    # cygwin-setup.exe --no-admin --quiet-mode --no-shortcuts --root "C:\cygwin64" --site "http://mirrors.aliyun.com/cygwin/" --local-package-dir "C:\cygwin64\packages" --packages  $packages_to_install
    $INSTALL packages_to_install

    echo "请在 ~/.bashrc 修改 PATH 环境变量,使得 /usr/bin/git 位于前面的位置, 
    也就是 首先用到的 git 是 cygwin 安装的,而非 winget 安装的git, 
    具体可通过 `which git` 查看, 如果是 /usr/bin/git 则没错,
    如果是 `/cygdrive/c/Program%20Files/Git` 则不行,因为两者的 home目录不一样 会有差异"
}

install_dev_env_openssh_server() {
    # 参考 https://www.cnblogs.com/managechina/p/18189889, 
    # 参考: https://learn.microsoft.com/zh-cn/windows-server/administration/openssh/openssh_install_firstuse?tabs=gui&pivots=windows-server-2025#enable-openssh-for-windows-server-2025

    # 检查 openssh 安装状态
    Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

    # 安装 OpenSSH 客户端
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
    # 安装 OpenSSH 服务器
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    # 设置 SSHD 服务自动启动
    Set-Service -Name sshd -StartupType 'Automatic'
    # 启动 SSHD 服务
    Start-Service sshd
    # 检查 SSH 服务器是否在侦听 22 端口：
    netstat -an | findstr /i ":22"
    # 5确保 Windows Defender 防火墙允许 TCP 22 端口的入站连接：
    Get-NetFirewallRule -Name *OpenSSH-Server* | select Name, DisplayName, Description, Enabled

    # 接下来请配置好 密钥对
}

# 启动 虚拟机相关功能.
enable_vm_function() {
    echo 'win+q  搜索 windows 功能, 勾选上 如下几个选下， 确定, 重启.
    1. virtual machine platform, 
    2. windows 沙盒, 
    3. windows 虚拟机监控程序平台, 
    4. hyper-v'

    echo 在进行下面的操作前, 先给 Windows 加个还原点. 防止出问题.

    # Enable Hyper-V using PowerShell
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    
}

install_and_config_basic_tool_for_shell() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 1>/dev/null
    git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z 1>/dev/null
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k 1>/dev/null
    cp ../homedir/global_aliases /etc/
    cp ../homedir/zsh_alias ~/.zsh_alias
    cp ../homedir/zshrc ~/.zshrc
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf 1>/dev/null
    ~/.fzf/install
    source ~/.zshrc

    [ ! -d $HOME/.tmux/plugins/tpm ] && {
        git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm 1>/dev/null
    }
    [ -f ~/.tmux.conf ] && mv ~/.tmux.conf ~/.tmux.conf.bak
    \cp ../homedir/tmux.conf ~/.tmux.conf
    tmux source ~/.tmux.conf

    echo 请进入 tmux 并且 按 `Ctrl+B` 然后按 大写 `I` 键 来安装 tmux 的插件.
}

# 需要安装好 cygwin 后 管理员权限下运行
# 小鹤双拼, 开启 微软拼音的小鹤双拼
# install_double_pinyin_for_ms_pinyin() {
#     # wget -O "$HOME\tmp\xhup.reg" "https://raw.githubusercontent.com/2015WUJI01/xhup-for-win10/refs/heads/master/xhup.reg"
#     # Start-Process regedit.exe -ArgumentList '/s xhup.reg' -Wait
#     # 下载并执行注册表文件
#     # wget -O "$HOME\tmp\xhup.reg" "https://raw.githubusercontent.com/2015WUJI01/xhup-for-win10/refs/heads/master/xhup.reg"

#     echo 'Windows Registry Editor Version 5.00

# [HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\CHS]
# "UserDefinedDoublePinyinScheme0"="小鹤双拼*2*^*iuvdjhcwfg^xmlnpbksqszxkrltvyovt"
# ' > "$HOME\tmp\xhup.reg"

#     Start-Process regedit.exe -ArgumentList "/s $HOME\tmp\xhup.reg" -Wait
# }

# 为微软输入法加上 小鹤双拼的 双拼方案
install_double_pinyin_for_ms_pinyin() {
    # 创建注册表文件
    cat <<EOF > /tmp/xhup.reg
Windows Registry Editor Version 5.00
[HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\CHS]
"UserDefinedDoublePinyinScheme0"="小鹤双拼*2*^*iuvdjhcwfg^xmlnpbksqszxkrltvyovt"
EOF

    # 执行注册表文件
    reg import `cygpath -w "/tmp/xhup.reg"`

    # 检查 reg import 命令是否执行成功
    if [ $? -eq 0 ]; then
        echo "reg import 命令执行成功！"
    else
        echo "reg import 命令执行失败！"
        echo "导入的文件是 $(cygpath -w /tmp/xhup.reg)"
        echo "以下是一些可能的解决方案和思路："
        echo "1. 检查注册表权限：确保你有权限修改注册表中的相关键值。"
        echo "2. 使用管理员权限运行脚本：尝试以管理员身份运行脚本。"
        echo "3. 手动导入注册表文件：尝试手动双击 .reg 文件，查看是否有错误提示。"
        echo "4. 使用 regedit 手动添加键值：如果导入失败，可以尝试使用 regedit 手动添加键值。"
    fi
}

install_apps() {
    start_time=$(date +%s)
    failed_apps=()

    # set -x
    for group in "${apps_groups[@]}"; do
        echo "======================"
        echo "Group: $group"
        eval "apps=(\"\${${group}[@]}\")"
        for appid in "${apps[@]}"; do
            echo '-------'
            # echo "APPID: $appid"
            echo -e "\e[32mAPPID: $appid\e[0m"

            # 如果 $appid 以 manually 开头，则跳过
            if [[ $appid == manually* ]]; then
                echo "请手动安装 $appid  并参考如下信息"
                grep "$appid" ./windows_apps.sh 
                echo
                continue
            fi
            
            # 不能对一些应用直接使其 地区改为 zh-cn, 假如没有的话就安装失败，而在 settings 已经指定好了 语言有中文，安装中文，没有则安装英文
            args=" --source winget"
            if [[ "$appid" == "Mozilla.Firefox" ]];then
                args=" --source winget  --locale en-US "
            fi
            
            if [[ $appid == msstore-* ]];then
                appid=`echo $appid | cut -d '-' -f 2-`
                args=" --source msstore "
            fi

            if winget list --id $appid > /dev/null 2>&1; then
                echo "已安装"
                echo
                continue
            fi
            # echo "winget install --id $appid $args --no-upgrade --accept-package-agreements --accept-source-agreements --exact --silent --disable-interactivity"
            if ! winget install --id $appid $args --no-upgrade --accept-package-agreements --accept-source-agreements --exact --silent --disable-interactivity; then
                failed_apps+=("$appid")
                echo
            fi

        done
        echo
    done
    end_time=$(date +%s)
    elapsed_time=$((end_time - start_time))
    echo "总耗时: $elapsed_time 秒"

    # 打印失败的包及其数量
    if [ ${#failed_apps[@]} -gt 0 ]; then
        echo "以下包安装失败:"
        for failed_app in "${failed_apps[@]}"; do
            echo " - $failed_app"
        done
        echo "失败包总数: ${#failed_apps[@]}"
        echo
        echo 请尝试使用 UniGetUI 安装或者 到官网下载安装包手动安装
    else
        echo "所有包安装成功！"
    fi
}


# ccleaner 无法使用命令行清理注册表,只能手动.
backup_regestry_before_clean_it_using_ccleaner() {
    start_time=$(date +%s)
    echo "开始备份 ccleaner 即将要清理无效项的注册表目录, 包括: 注册表清理程序  缺失的共享 DLL 等"

    # 定义备份文件路径
    BACKUP_DIR="/cygdrive/c/Users/$(whoami)/Documents/CCleaner_Registry_Backup"
    [ ! -d $BACKUP_DIR ] && mkdir -p $BACKUP_DIR
    backup_file="$BACKUP_DIR/total.reg"

    # 注册表清理程序
    # 缺失的共享 DLL
    # 未使用的文件扩展名
    # ActiveX 和类问题
    # 类型库
    # 应用程序
    # 字体
    # 应用程序路径
    # 帮助文件
    # 安装程序
    # 过时的软件
    # 启动时运行
    # 开始菜单排序
    # MUI 缓存
    # 声音事件
    # Windows 服务

    # 定义需要备份的注册表路径
    registry_keys=(
        "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\SharedDLLs"
        "HKEY_CLASSES_ROOT"
        "HKEY_CLASSES_ROOT\\CLSID"
        "HKEY_CLASSES_ROOT\\TypeLib"
        "HKEY_LOCAL_MACHINE\\SOFTWARE"
        "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts"
        "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths"
        # "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\Help"
        "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Installer"
        "HKEY_LOCAL_MACHINE\\SOFTWARE"
        "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run"
        "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"
        "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\MenuOrder"
        "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders"
        "HKEY_CURRENT_USER\\AppEvents\\EventLabels"
        "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services"
    )

    # 创建一个空的备份文件
    touch "$backup_file"

    # 遍历每个注册表路径并导出到临时文件
    for key in "${registry_keys[@]}"; do
        key_name=$(echo $key | tr '\\\\' '_' | tr -d ':')
        temp_file="$BACKUP_DIR/$key_name.reg"
        touch $temp_file
        dos_temp_file=$(cygpath -w "$temp_file")
        reg export "$key" "$dos_temp_file" /y 1>/dev/null
        cat "$dos_temp_file" >> "$backup_file"
    done

    end_time=$(date +%s)
    elapsed_time=$((end_time - start_time))
    echo "总耗时: $elapsed_time 秒"
    echo "备份完成。备份文件保存为: $(cygpath -w "$backup_file")"
}

config_env_variable() {
    ln -s /cygdrive/c/Program\ Files/WinRAR/Rar.exe  /cygdrive/c/cygwin64/bin/rar
}


# 有洁癖的可以使用
optimize_windows_apps() {

    # 删除电脑微信的 小程序/公众号 功能, 让他低占用保持聊天功能
    user=$(whoami)
    rm -rf /cygdrive/c/Users/$user/AppData/Roaming/Tencent/WeChat/XPlugin/Plugins/RadiumWMPF
    touch /cygdrive/c/Users/$user/AppData/Roaming/Tencent/WeChat/XPlugin/Plugins/RadiumWMPF

}