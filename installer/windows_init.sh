#!/usr/bin/bash
# set -x
set -e
source ./windows_apps.sh

# 请用 admin 模式执行以下命令
# set_profile() {
#     mkdir -p "C:\Users\Public\Downloads\winget_cache"
#     # 这里会乱码
#     content=
# '
# [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# $env:WINGET_CACHE = "C:\Users\Public\Downloads\winget_cache"
# $env:WINGET_CACHE_FOLDER = "C:\Users\Public\Downloads\winget_cache"
# '
#     # 设置 utf-8
#     # echo '[Console]::OutputEncoding = [System.Text.Encoding]::UTF8' >> $PROFILE.AllUsersAllHosts
#     # winget 设置缓存
#     # echo '$env:WINGET_CACHE = "C:\Users\Public\Downloads\winget_cache"' >> $PROFILE.AllUsersAllHosts
# }

# install_choco() {
#     # 官方推荐的检测
#     if ((Get-ExecutionPolicy) -eq 'Restricted') {
#         Set-ExecutionPolicy AllSigned -Scope CurrentUser -Force
#         Set-ExecutionPolicy Bypass -Scope Process
#     }

#     # 官方一键安装脚本
#     Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#     # 配置 Chocolatey 软件安装默认位置, 软件安装包缓存
#     # mkdir -p D:\ChocolateyProgram\lib  
#     mkdir D:\ChocolateyCache
#     choco config set cacheLocation D:\ChocolateyCache\

#     # 验证安装包缓存位置配置正确
#     choco config get cacheLocation

#     # 设置 Choco 环境变量，使得默认安装位置为  D:\ChocolateyProgram
#     # sudo powershell -Command "[System.Environment]::SetEnvironmentVariable('ChocolateyInstall', 'D:\ChocolateyProgram', 'Machine')"

#     # 启动新的 powershell 检查 是否生效
#     # 需要新启动一个 powershell 
#     if ($env:ChocolateyInstall) {
#         Write-Output "ChocolateyInstall 环境变量设置为: $env:ChocolateyInstall"
#     } else {
#         Write-Output "ChocolateyInstall 环境变量未设置好."
#     }
# }

# powershell
# winget_change_mirror_site() {
#     # 检查 WinGet 版本
#     $wingetVersion = (winget --version)
#     $versionPattern = '(\d+)\.(\d+)\.(\d+)'
#     if ($wingetVersion -match $versionPattern) {
#         $majorVersion = [int]$matches[1]
#         $minorVersion = [int]$matches[2]
#     }
    
#     # 替换 WinGet 源
#     if ($majorVersion -gt 1 -or ($majorVersion -eq 1 -and $minorVersion -ge 8)) {
#         # WinGet >= 1.8
#         winget source remove winget
#         winget source add winget https://mirrors.ustc.edu.cn/winget-source --trust-level trusted
#     } else {
#         # WinGet <= 1.7
#         winget source remove winget
#         winget source add winget https://mirrors.ustc.edu.cn/winget-source
#     }
    
#     # 检查是否出现 0x80073d1b 错误
#     try {
#         winget source update
#     } catch {
#         if ($_.Exception.Message -match "0x80073d1b") {
#             Write-Host "出现 0x80073d1b : smartscreen reputation check failed. 错误，请检查网络连接或暂时关闭 SmartScreen。"
#         } else {
#             throw $_
#         }
#     }
    
#     # 提供重置为官方地址的命令
#     Write-Host "如需重置为官方地址，执行以下命令即可："
#     Write-Host "winget source reset winget"
# }

check_package_domain() {


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

setup_before_anything_from_community() {

    # 支持中文
    tee -a $HOME/.bashrc >/dev/null <<EOT
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
EOT

    # cygwin rsync 安装
    curl -O https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
    install apt-cyg /bin
    chmod +x /bin/apt-cyg

    echo '打开cygwin的安装文件，继续安装两个包: lynx, wget, libcurl, curl 等等 ，安装好以后, 将 cygwin 的 bin 目录添加到系统的环境变量 PATH 中'

    # 手动安装打开 cygwin 的 gui 安装两个包
    # lynx, wget curl. 用 apt-cyg 装会提示缺库，我不知道应该装哪些库.

    # 安装 apt-cyg 包管理器
    lynx -source rawgit.com/transcode-open/apt-cyg/master/apt-cyg > apt-cyg
    install apt-cyg /bin

    # 修改 包管理器的源为 阿里云
    cp /etc/setup/setup.rc /etc/setup/setup.rc.bak
    sed -i 's|^last-mirror=.*|last-mirror=http://mirrors.aliyun.com/cygwin/|' /etc/setup/setup.rc

    # 更新包管理器, 并安装常用包
    apt-cyg update
    # 安装依赖库
    apt-cyg install libdialog15 libcurl4 libxxhash0 libsodium23 
    # 安装 常用软件包
    git curl vim bash-completion the_silver_searcher  vim dialog rsync

}

# 请使用 管理员模式打开 powershell，使得免受 “你确定软件对你设备的更改吗”该类的提示。
install_tencent_app() {
    # 通过如下命令确定 包的下载url 域名都是 腾讯的,没毛病
    # 所有 ID 以 Tencent 开头， source 为 winget 的都没问题
    git clone https://github.com/microsoft/winget-pkgs.git /tmp/winget-pkgs && ag PackageUrl /tmp/winget-pkgs/manifests/t/Tencent --nonumbers| ag 'https.*' -o | sed -rn 's~https://~~g; s~/.*~~g;/.*/p' | sort|uniq
    # winget install Tencent.WeChat --scope machine --accept-package-agreements --exact
    # winget install --id Tencent.WeChat --scope machine --accept-package-agreements --exact --source winget --architecture x64
    winget install --id Tencent.WeChat --accept-package-agreements --accept-source-agreements --exact --source winget --architecture x64 --silent  --disable-interactivity 
    winget install --id Tencent.QQMusic --accept-package-agreements --accept-source-agreements --exact --source winget --silent  --disable-interactivity
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




check_package_domain