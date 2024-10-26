
# 请用 admin 模式执行以下命令
function set_profile {
    mkdir -p "C:\Users\Public\Downloads\winget_cache"
    # 这里会乱码
    content=
'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:WINGET_CACHE = "C:\Users\Public\Downloads\winget_cache"
$env:WINGET_CACHE_FOLDER = "C:\Users\Public\Downloads\winget_cache"
'
    # 设置 utf-8
    # echo '[Console]::OutputEncoding = [System.Text.Encoding]::UTF8' >> $PROFILE.AllUsersAllHosts
    # winget 设置缓存
    # echo '$env:WINGET_CACHE = "C:\Users\Public\Downloads\winget_cache"' >> $PROFILE.AllUsersAllHosts
}

function install_choco {
    # 官方推荐的检测
    if ((Get-ExecutionPolicy) -eq 'Restricted') {
        Set-ExecutionPolicy AllSigned -Scope CurrentUser -Force
        Set-ExecutionPolicy Bypass -Scope Process
    }

    # 官方一键安装脚本
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    # 配置 Chocolatey 软件安装默认位置, 软件安装包缓存
    # mkdir -p D:\ChocolateyProgram\lib  
    mkdir D:\ChocolateyCache
    choco config set cacheLocation D:\ChocolateyCache\

    # 验证安装包缓存位置配置正确
    choco config get cacheLocation

    # 设置 Choco 环境变量，使得默认安装位置为  D:\ChocolateyProgram
    # sudo powershell -Command "[System.Environment]::SetEnvironmentVariable('ChocolateyInstall', 'D:\ChocolateyProgram', 'Machine')"

    # 启动新的 powershell 检查 是否生效
    # 需要新启动一个 powershell 
    if ($env:ChocolateyInstall) {
        Write-Output "ChocolateyInstall 环境变量设置为: $env:ChocolateyInstall"
    } else {
        Write-Output "ChocolateyInstall 环境变量未设置好."
    }
}

function install_packages {

    # 可能会存在一些小毛病，例如 安装包 url 发生变化。导致没法安装，这时需要手动安装.
    # 首先通过命令行自动化安装，接着通过 microsoft store 安装, 接着通过第三方应用商店如小米腾讯安装, 最后通过应用官网安装

    # 这里安装目录中的空格会导致最终安装在 `D:\Program` 该目录下，所以不能又空格
    # choco install vscode --install-arguments="'/DIR=D:\Program Files\VSCode'" --params "/NoContextMenuFiles /NoContextMenuFolders"
    # 以下命令会将 vscode 文件都安装在 VSCode
    # choco install vscode --install-arguments="'/DIR=D:\Program_Files\VSCode'" --params "/NoContextMenuFiles /NoContextMenuFolders"

    # 全部默认安装到C盘
    # 编程开发
    choco install vscode  neovim  git  cygwin  nexttrace -y
    # 依赖
    choco install nodejs -y
    # 浏览器
    choco install firefox googlechrome -y
    # 影音娱乐
    choco install Aotplayer netease-cloudmusic  mpv -y 
    # 办公效率
    choco install bitwarden winrar 7zip  typora -y
    # 美化
    choco install mactype
    # 系统工具
    choco install synologydrive everything  synology-activebackup-for-business-agent  ntop.portable procexp -y
    # 社交聊天
    choco install telegram -y

    # 再手动通过应用商店安装如下软件
    # utools wechat tim I. I I I I. Adam and Treasurer's house. I I. I How are you USB I never would to say like it was just a Play song Vala Tumi Na Na Na Na Na Na Na No worries about. Check Allah Ma Nibha I. Review Fashion Amar Kaohar. France USBI see that. Indian survey translator. Hey Cortana, It's enough. parsecyuanliao-utools 火绒

    # 微软应用商店

    # cygwin rsync 安装
    curl -O https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
    install apt-cyg /bin
    chmod +x /bin/apt-cyg

    echo '打开cygwin的安装文件，继续安装两个包: lynx, wget, libcurl, curl 等等 ，安装好以后, 将 cygwin 的 bin 目录添加到系统的环境变量 PATH 中'

    # 破解版
    # emby 开心版,  酷我音乐, charles, fiddler, navicat, office, visio, dvdfab, powerdvd, FoxitPhantomPDF, ccleaner

    # 更优雅的文件管理器
    # Files https://files.community/appinstallers/Files.stable.appinstaller

    # 更优雅的桌面程序 仿真 mac
    # mactyp mydockfinder
    # https://www.mydockfinder.com/

    # 手动安装
    # incogniton

    # 老版
    # 电影和电视(能播放VR)
}


winget_change_mirror_site {
    # 检查 WinGet 版本
    $wingetVersion = (winget --version)
    $versionPattern = '(\d+)\.(\d+)\.(\d+)'
    if ($wingetVersion -match $versionPattern) {
        $majorVersion = [int]$matches[1]
        $minorVersion = [int]$matches[2]
    }
    
    # 替换 WinGet 源
    if ($majorVersion -gt 1 -or ($majorVersion -eq 1 -and $minorVersion -ge 8)) {
        # WinGet >= 1.8
        winget source remove winget
        winget source add winget https://mirrors.cernet.edu.cn/winget-source --trust-level trusted
    } else {
        # WinGet <= 1.7
        winget source remove winget
        winget source add winget https://mirrors.cernet.edu.cn/winget-source
    }
    
    # 检查是否出现 0x80073d1b 错误
    try {
        winget source update
    } catch {
        if ($_.Exception.Message -match "0x80073d1b") {
            Write-Host "出现 0x80073d1b : smartscreen reputation check failed. 错误，请检查网络连接或暂时关闭 SmartScreen。"
        } else {
            throw $_
        }
    }
    
    # 提供重置为官方地址的命令
    Write-Host "如需重置为官方地址，执行以下命令即可："
    Write-Host "winget source reset winget"
}

check_package_domain {
    git clone https://github.com/microsoft/winget-pkgs.git /tmp/winget-pkgs 

    # the following code would be executed in zsh shell
    appids=(
        "Tencent.WeChat"
        "Tencent.TIM"
        "Tencent.QQMusic"
        "Telegram.TelegramDesktop"
        "Synology.ActiveBackupForBusinessAgent"
        "Synology.ChatClient"
        "Synology.DriveClient"
        "Synology.NoteStationClient"
        "Synology.Assistant"
    )

    subdirs=()

    # Collect unique subdirs
    for appid in "${appids[@]}"; do
        subdir=$(echo $appid | awk -F. '{print tolower(substr($1, 1, 1)) "/" $1}')
        subdirs+=("$subdir")
    done

    # Remove duplicates
    subdirs=($(printf "%s\n" "${subdirs[@]}" | sort -u))

    # Loop through unique subdirs and run commands
    for subdir in "${subdirs[@]}"; do
        echo '-----------------'
        echo "subdir: $subdir"
        echo
        echo '域名列表,请检查域名是否有伪造'
        ag PackageUrl ~/tmp/winget-pkgs/manifests/${subdir} --nofilename --nonumbers | \grep 'https:\/\/[a-zA-Z0-9.-]+' -Eoi | sort | uniq
        echo
    done

}

winget_appids_src_winget=(
    # AI助手
    "ByteDance.Doubao"                              # 字节跳动旗下的豆包 AI 大模型助手, 免费

    # 编程开发
    "Microsoft.VisualStudioCode"                    # 微软开发的热门的开源编程IDE
    "Neovim.Neovim"                                 # 将 vim 搬到 Windows 上用
    "Git.Git"                                       # 版本管理工具
    "Cygwin.Cygwin"                                 # Windows 上的 unix like 终端
    #"Nexttrace"                                    # 路由追踪工具
    "voidtools.Everything.Cli"                      # everything cli
    "Genymobile.scrcpy"                             # 电脑控制手机
    "Google.PlatformTools"                          # adb 安卓手机调试工具
    "Python.Python.3.13"                            # python
    "IPIP.BestTrace"                                # 路由追踪
    "DevToys-app.DevToys"                           # 编程开发瑞士军刀, 不用再在网上找一些信不过的网页做啥 json 转换等等
    "Axosoft.GitKraken"                             # 漂亮的 git 客户端， 再也不用傻傻搞不清楚了
    "Telerik.Fiddler.Everywhere"                    # Windows 抓包工具

    # 依赖
    "OpenJS.NodeJS"                                 

    # 浏览器
    "Mozilla.Firefox"                               # 主要看中他的 session container # winget install Mozilla.Firefox --locale en-US
    "Google.Chrome"                                 # 谷歌浏览器

    # 影音娱乐
    "Daum.PotPlayer"                                # 目前近乎万能的播放器
    "Tencent.QQMusic"                               # qq音乐，就是音乐库多, 但是搜到的在线音乐不能播放本地的音源，只能在本地音乐界面播放。
    "NetEase.CloudMusic"                            # 网易云

    # 影音技术
    "Gyan.FFmpeg"                                   # 音视频编码和转码，非常强大
    "9N0866FS04W8"                                  # Dolby Access, 淘宝 10块钱的杜比音效/视界激活码
    "9n4wgh0z6vhq"                                  # hevc 8k 视频解码包,笔记本已经装好 来自设备制造商的视频扩展 hevc HEVC Video Extensions from Device Manufacturer, https://apps.microsoft.com/detail/9n4wgh0z6vhq?ocid=pdpshare&hl=en-us&gl=US
    "9NMZLZ57R3T7"                                  # hevc 视频扩展 https://www.microsoft.com/store/productId/9NMZLZ57R3T7?ocid=pdpshare
    "9pltg1lwphlf"                                  # Dolby Vision Extensions https://apps.microsoft.com/detail/9pltg1lwphlf?ocid=libraryshare&hl=en-us&gl=US
    "9nvjqjbdkn97"                                  # Dolby Digital Plus decoder for PC OEMs  https://apps.microsoft.com/detail/9nvjqjbdkn97?ocid=libraryshare&hl=en-us&gl=US

    # 办公效率
    "RARLab.WinRAR"                                 # 解压缩
    "appmakes.Typora"                               # 所见即所得 优雅的 markdown 编辑工具
    "Yuanli.uTools"                                 # 桌面级的超级工具，按Alt+空格，连接 AI, 搜索引擎, 本地应用打开, 本地文件搜索.
    "7zip.7zip"                                     # 开源解压缩软件，支持多种格式
    "copyQ"                                         # 剪贴板工具
    "Microsoft.PowerToys"                           # 瑞士军刀
    "Sogou.SogouInput"                              # 搜狗输入法

    # 社交聊天
    "Tencent.WeChat"                                # 微信
    "Tencent.TIM"                                   # 简洁 QQ
    "Telegram.TelegramDesktop"                      # 小飞机

    # 美化
    "MacType.MacType"                               # 旨在为 Windows 提供类似 macOS 的字体渲染效果, 没感觉有啥区别

    # 系统工具
    "Synology.Assistant"                            # 群晖助手，发现管理群晖设备
    "Microsoft.Sysinternals.ProcessExplorer"        # 升级版专业版的任务管理器
    "gsass1.NTop"                                   # 命令行的任务管理器
    "voidtools.Everything"                          # everything 高性能,超快响应的 windows 文件搜索工具
    # "Win10Debloat"
    "9NTXGKQ8P7N0"                                  # Cross Device Experience, 连手机

    # 安全
    "Bitwarden.Bitwarden"                           # 密码即服务
    "XPDNH1FMW7NB40"                                # 火绒安全软件,告别360,功能强大全方位防护,无广告,不弹窗,不流氓,无全家桶捆绑

    # 云存储,同步,备份
    "Synology.ActiveBackupForBusinessAgent"         # 群晖 的 windows系统备份工具
    "Synology.DriveClient"                          # 群晖的功能上像是 Onerive 的备份同步工具
    "Baidu.BaiduNetdisk" 							# 百度网盘
    "Alibaba.aDrive" 							    # 阿里网盘
    
    # 网络
    "2dust.v2rayN"                                  # 魔法上网
    "ClashVergeRev.ClashVergeRev"                   # 魔法上网
    "Youqu.ToDesk"                                  # 远程桌面, 修电脑
    "Parsec.Parsec"                                 # 串流远程桌面, 丝滑, 打游戏

    # 阅读
    "GauzyTech.NeatReader"                          # 电子书阅读, 如 mobi, epub
    "9WZDNCRFHWQT"                                  # Drawboard, 免费的沉浸式 pdf 阅读手写笔记器, 以前收费现在阶梯收费,使用老版本的滑还是有足够的手写功能
    "9NBLGGH67WLK"                                  # pdf reader, PDF Reader - View and Edit PDF
    "9WZDNCRDJXP4"                                  # 比较丝滑的 pdf 阅读编辑器，就是额头有点大

    # office 办公
    "Kingsoft.WPSOffice"                            # WPS

)

# 系统工具
winget_appids_form_src_msstore=(
)

manually_appids_from_app_site=(
    "FIles" # "https://files.community/appinstallers/Files.stable.appinstaller"
    "HEVC"
    "coder"
    "dolby" # related
    "clouddrive2"
    "wps"
    "TrafficMonitor" # 监控 cpu/gpu/网络等 usage, 温控信息, 置于任务栏中  # "https://github.com/zhongyang219/TrafficMonitor/releases/latest"
)


winget_install_packakges_from_msstore {
}

winget_install_packages_from_community {
    # 编程开发
    vscode  neovim  git  cygwin  nexttrace -y
    # 依赖
    firefox googlechrome -y
    # 影音娱乐
    Potplayer netease-cloudmusic  mpv -y 
    # 办公效率
    bitwarden winrar typora -y
    # 美化
    mactype
    # 系统工具
    synologydrive everything  synology-activebackup-for-business-agent  ntop.portable procexp -y
    # 社交聊天
    telegram -y

    # 再手动通过应用商店安装如下软件

    # 微软应用商店

    # cygwin rsync 安装
    curl -O https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
    install apt-cyg /bin
    chmod +x /bin/apt-cyg

    echo '打开cygwin的安装文件，继续安装两个包: lynx, wget, libcurl, curl 等等 ，安装好以后, 将 cygwin 的 bin 目录添加到系统的环境变量 PATH 中'

    # 破解版
    # emby 开心版,  酷我音乐, charles, fiddler, navicat, office, visio, dvdfab, powerdvd, FoxitPhantomPDF, ccleaner

    # 更优雅的文件管理器
    # Files https://files.community/appinstallers/Files.stable.appinstaller

    # 更优雅的桌面程序 仿真 mac
    # mactyp mydockfinder
    # https://www.mydockfinder.com/

    # 手动安装
    # incogniton

    # 老版
    # 电影和电视(能播放VR)
}

install_social_media_app {
    ag PackageUrl ~/tmp/winget-pkgs/manifests/Telegram/Tencent --nofilename --nonumbers| ag 'https://[^\/]+' -o | sort|uniq   
    winget install --id Telegram.TelegramDesktop --accept-package-agreements --accept-source-agreements --exact --source winget --architecture x64 --silent  --disable-interactivity --scope machine
}

# 请使用 管理员模式打开 powershell，使得免受 “你确定软件对你设备的更改吗”该类的提示。
function install_tencent_app {
    # 通过如下命令确定 包的下载url 域名都是 腾讯的,没毛病
    # 所有 ID 以 Tencent 开头， source 为 winget 的都没问题
    git clone https://github.com/microsoft/winget-pkgs.git /tmp/winget-pkgs && ag PackageUrl /tmp/winget-pkgs/manifests/t/Tencent --nonumbers| ag 'https.*' -o | sed -rn 's~https://~~g; s~/.*~~g;/.*/p' | sort|uniq
    # winget install Tencent.WeChat --scope machine --accept-package-agreements --exact
    # winget install --id Tencent.WeChat --scope machine --accept-package-agreements --exact --source winget --architecture x64
    winget install --id Tencent.WeChat --accept-package-agreements --accept-source-agreements --exact --source winget --architecture x64 --silent  --disable-interactivity 
    winget install --id Tencent.QQMusic --accept-package-agreements --accept-source-agreements --exact --source winget --silent  --disable-interactivity
}


# 根据关键词 utools 使用 winget 搜索并过滤出 msstore 中的软件来安装
function install_utools_from_msstore {
    ag PackageUrl ~/tmp/winget-pkgs/manifests/y/Yuanli --nonumbers| ag 'https.*' -o | sed -rn 's~(https://[^/])+/.*~\1~g;/.*/p' | sort|uniq
    winget install --id Yuanli.uTools --accept-package-agreements --accept-source-agreements --exact --source winget --architecture x64 --silent  --disable-interactivity 
}


# 需要安装好 cygwin 后 管理员权限下运行
# 小鹤双拼, 开启 微软拼音的小鹤双拼
install_double_pinyin_for_ms_pinyin {
    # wget -O "$HOME\tmp\xhup.reg" "https://raw.githubusercontent.com/2015WUJI01/xhup-for-win10/refs/heads/master/xhup.reg"
    # Start-Process regedit.exe -ArgumentList '/s xhup.reg' -Wait
    # 下载并执行注册表文件
    # wget -O "$HOME\tmp\xhup.reg" "https://raw.githubusercontent.com/2015WUJI01/xhup-for-win10/refs/heads/master/xhup.reg"

    echo 'Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\CHS]
"UserDefinedDoublePinyinScheme0"="小鹤双拼*2*^*iuvdjhcwfg^xmlnpbksqszxkrltvyovt"
' > "$HOME\tmp\xhup.reg"

    Start-Process regedit.exe -ArgumentList "/s $HOME\tmp\xhup.reg" -Wait
}

function Show-Menu {
    param (
        [string]$prompt = '请选择你要安装的软件的类别'
    )

    Write-Host "1.  [ ] 安装 编程开发工具"
    Write-Host "2.  [ ] 安装重要依赖"
    Write-Host "3.  [ ] 安装浏览器"
    Write-Host "4.  [ ] 安装影音娱乐"
    Write-Host "5.  [ ] 安装办公效率"
    Write-Host "6.  [ ] 安装美化工具"
    Write-Host "7.  [ ] 安装系统工具"
    Write-Host "8.  [ ] 安装社交聊天工具"
    Write-Host "9.  退出"

    $selection = Read-Host $prompt
    return $selection
}

function Install-Packages {
    param (
        [array]$packages
    )

    $selectedPackages = $packages | Out-GridView -Title "选择要安装的软件包" -PassThru

    Write-Host "你选择了以下软件包："
    foreach ($package in $selectedPackages) {
        Write-Host $package
    }

    # foreach ($package in $selectedPackages) {
    #     choco install $package -y
    # }

}

$programmingTools = @("vscode", "neovim", "git", "gh", "ag", "httpie", "cygwin")
$dependencies = @("nodejs")
$browsers = @("firefox", "googlechrome")
$entertainment = @("potplayer", "netease-cloudmusic", "mpv")
$productivity = @("bitwarden", "winrar", "7zip", "typora")
$customization = @("mactype")
$systemTools = @("ccleaner", "synologydrive", "everything", "synology-activebackup-for-business-agent")
$social = @("telegram")

while ($true) {
    $choice = Show-Menu

    switch ($choice) {
        1 {
            Install-Packages -packages $programmingTools
        }
        2 {
            Install-Packages -packages $dependencies
        }
        3 {
            Install-Packages -packages $browsers
        }
        4 {
            Install-Packages -packages $entertainment
        }
        5 {
            Install-Packages -packages $productivity
        }
        6 {
            Install-Packages -packages $customization
        }
        7 {
            Install-Packages -packages $systemTools
        }
        8 {
            Install-Packages -packages $social
        }
        9 {
            break
        }
        default {
            Write-Host "无效的选择，请重新选择。"
        }
    }
}


fetch("https://c.y.qq.com/v8/fcg-bin/fcg_v8_playlist_cp.fcg?newsong=1&id=9354585102&format=json&inCharset=GB2312&outCharset=utf-8").then(data => data.json()).then(data => {
    console.log(Array.from(data.data.cdlist).flatMap(u => u.songlist).map(m => m.name + " - " + Array.from(m.singer).map(c => c.name).reduce((s1, s2) => s1 + "," + s2)).reduce((s1, s2) => s1 + '\n' + s2))
})