#!/usr/bin/bash

set -e

# 以下所有注释的格式是  "appid" # 描述 # 备注, 方便处理成表格
# 描述不适合太长

# 无缝 随身 协同 办公
# 云空间, 设备互联, 有缝协同
co_workspace_anywhere=(
    "manually-猫头鹰文件"                           # 国产多端网盘(支持国内网盘和少部分国外网盘)聚合文件管理+同步软件 # 收费
    "manually-termux"                              # 安卓设备的终端模拟器
    "manually-foldersync"                          # 多端文件夹同步软件,还可以进行 本地<->远端(国外网盘,webdav)同步
    "manually-clouddrive"                          # 所有设备, 需要考虑网络安全问题(http 裸奔, 在不受信任的网络里裸奔)

)


# workspace anywhere 中的 共享存储
# 网盘,同步,备份
netdisk=(
    # 网络存储层,同步层,备份层

    #"Alist.Alist"                                  # 支持国内外众多网盘的挂载并以 webdav 提供服务
    # "Microsoft.OneDrive"                          # 十分完美的跨平台同步应用(双向同步 冲突解决 支持文件历史版本 提醒 无缝融合Windows使用),国内除世纪互联外难以使用
    "Baidu.BaiduNetdisk" 							# 百度网盘: 功能丰富 量大管饱, 支持10设备登录,支持双向增量同步, 三方支持不友好. 适合工作数据
    "Alibaba.aDrive" 							    # 阿里网盘: 功能相对不丰富,对于工作党最重要的功能没有:提供文件历史版本的双向增量同步功能，svip量大管饱,10设备; 加钱后三方支持友好. 可以安装各种折腾应用，不过最大1T流量。
    "manually-clouddrive"                          # 网盘聚合再挂载到无感的本地文件夹,webdav,自动备份任务,秒传,自动加密解密,流媒体播放
    # "115.115Chrome"                                 # 115 网盘, 做加密备份盘和中转盘

    # nas 的备份客户端
    "Synology.DriveClient"                          # 群晖的文件夹双向增量同步工具,支持历史版本. 像是 Onerive 的备份同步工具
    "Synology.Assistant"                            # 群晖助手，发现管理群晖设备
    # 群晖备份还原整个 windows系统的工具
    "Synology.ActiveBackupForBusinessAgent"         # 群晖 的 windows系统备份工具
    "manually-Synology Hyper Backup Explorer"       # 用于浏览、解码和提取 Hyper Backup 库中不同版本备份数据的桌面工具
    "manually-Synology Active Backup for Business 还原媒体建立工具" 
    "manually-Synology Active Backup for Business 还原向导"
    # 群晖 cloudsync 解密工具
    "manually-Synology Cloud Sync Decryption Tool"  # cloudsync 加密的内容的解密工具
    # 群晖方便的监控平台
    "manually-Synology Storage Console for Windows" # Synology Storage Console for Windows 是 Windows 上的一个存储管理工具，可帮助管理员简化对多个 Synology NAS 的监控。安装 Storage Console 后，您可以直接从 DSM 获取应用程序一致性快照。

    # 同步层 : PC 和 安卓端
    # "9NW9NWHZLMW6"                                  # 猫头鹰文件，截止目前 2024/11/1，支持国内多个网盘商，提供云端和本地的双向增量同步功能, 无法自定义同步的一些细节，如冲突解决, 同步删除操作等.
    "manually-resilio"                              # 无服务器 P2P 多设备同步一个文件夹会像bittorrent一样. 具有 Onedrive 的同步功能和分享功能, (文件占位符)释放/保留/. 官网:https://www.resilio.com/sync/, 参考教程文章: https://linux.do/t/topic/186892
    "manually-goodsync"                             # p2p sync, anywhere <-> anywhere 实际上电脑内部就可以. 经过测试在公网内从云端到手机安卓，走的是小水管服务器. 融合多个存储平台，统一管理，并在这些存储的基础上，建立一个含有版本控制等功能的同步空间。 P2P 链接. 跨平台. pro 版收费, 用例 https://linux.do/t/topic/186169
    "manually-foldersync"                           # 安卓 <=> 云端. folder sync, 跟 goodsync 有些类似，但是没有版本控制等等。
    "manualy-android-foldersync-clouddrive2-rcx"   # 联合提供文件同步服务.
        # - 任意一边如果是空文件夹同步会出错, 不同步删除操作.
        # - foldersync 配合 goodsync 使用, 定期 diff 一下
)

# 基于 Netdisk 的跨平台应用层
co_workspace_anywhere_apps=(

    # 手机自带应用 kit
    # 日历
    # 联系人
    # 短信
    # mail
    # todo, 便签

    # noting 笔记
    # noting
    # 以下两个 markdown 工具配合 百度网盘/onedrive 的同步功能 都是跨设备的好工具, 其中 obsidian 支持安卓端, 如何不用 百度网盘和 Onedrive 可能需要自己搭 webdav 和采取一些额外的同步工具
    "appmakes.Typora"                               # 所见即所得 优雅强大的 markdown 编辑工具, 但被指出当行数达到几千行时会遇到性能问题。
    "Obsidian.Obsidian"                             # 所见即所得 优雅强大的 markdown 编辑工具, 多插件支持,
    "Joplin.Joplin"                                 # 跟 EverNote 相似, 支持 webdav 同步

    # 阅读
    # reading
    # "GauzyTech.NeatReader"                          # 电子书阅读, 如 mobi, epub
    "manually-9WZDNCRFHWQT"                        # Drawboard, 免费的沉浸式 pdf 阅读手写笔记器, 以前收费现在阶梯收费,使用老版本的滑还是有足够的手写功能. 配置可通过账号同步
    # "9NBLGGH67WLK"                                  # pdf reader, 挺丝滑,额头大, PDF Reader - View and Edit PDF
    # "9WZDNCRDJXP4"                                  # 比较丝滑的 pdf 阅读编辑器，就是额头有点大
    "manually-weread"                               # https://weread.qq.com/微信阅读, 跨平台优雅

    # office 办公套件
    # office_kit
    "Kingsoft.WPSOffice"                            # WPS
    "manually-microsoft-office"                       # microsoft offie 个人版
    "NetEase.MailMaster"                            # 网易邮箱大师

    # 学生应用
    # 远程串流
    # for_student
    "Parsec.Parsec"                                 # 拿着平板(+充电宝)上课、去图书馆, 串流到宿舍的电脑，性能\续航 无敌，只有最强没有之一. 还能大把游戏惊艳一下隔壁的小伙伴
    # 字典
    # "EuSoft.Eudic"                                  # 欧陆词典, 英语学习者 或者严肃查词典必备, 请到淘宝或者闲鱼购买激活码, 到淘宝购买词典扩充包或者下载我提供的几个包
    # "xiaoyifang.GoldenDict-ng"                      # Golendict 查单词，干净古老的可扩展查词工具。
    # "noteexpress"                                 # 文献管理工具，国产软件，到闲鱼买个吧, https://www.inoteexpress.com/aegean/
    # "ClarivateAnalytics.EndNote"                    # EndNote, 收费，到某宝小黄鱼买个
    # "9WZDNCRFHWQT"                                  # Drawboard, 免费的沉浸式 pdf 阅读手写笔记器, 以前收费现在阶梯收费,使用老版本的滑还是有足够的手写功能
    # "DigitalScholar.Zotero"                         # Zotero 是一个免费且易用的文献管理工具，可以帮助你收集、整理、引用和分享你的研究资讯。
    # "Elsevier.MendeleyReferenceManager"             # Mendeley 是一款免费的跨平台文献管理软件，同时也是一个在线的学术社交网络平台，可一键抓取网页上的文献信息添加到个人图书馆中；比较适合本地操作和大量 PDF 的文件管理。
    # "Overleaf"                                    # 可以自己搭建服务器

    # media_entertainment_and_audio_vido_tech=(
    # 多媒体, 影音娱乐
    # 视频
    "Daum.PotPlayer"                                # 目前近乎万能的播放器, 新版支持杜比视界, 见帖子汇总:https://v2ex.com/t/1023976
    "Tencent.QQMusic"                               # qq音乐，就是音乐库多, 但是搜到的在线音乐不能播放本地的音源，只能在本地音乐界面播放。
    "NetEase.CloudMusic"                            # 网易云
    "lyswhut.lx-music-desktop"                      # 一款开源的音乐播放器, 支持自定义音源. 风格简洁, 歌曲元数据齐全洛雪音乐播放器, .
    "maotoumao.MusicFree"                           # 跟 lx-music 有点类似, 但是功能更加完善, 同样跨平台, 支持 webdav 同步配置 同步歌单.
    "manually-BBDown"                               #
    "manually-kwmusic"                              # 酷我音乐下载歌曲
    # "filmly"                                      # 不支持windows, 跨平台 https://filmly.163.com/
    "XBMCFoundation.Kodi"                           # 开源 强大的跨平台多媒体播放器, 能够刮削
    "manually-emby"                                 # emby client for windows
    "manually-powerdvd"                             # 蓝光播放器
    "manually-edifier-tempohub"                     # 漫步者耳机电脑软件
    # 相册,音乐,文档,录音,视频 通过clouddrive2增量加密备份到云盘就好, 多端重新解密出来同步, 偶尔 diff 一下
    # 基础通信: 联系人/短信 使用qq同步助手吧, 感觉就是用来注册账号/收发验证码
    # 笔记/日历/待办 使用第三方的软件,已经解决好同步问题
)

# 内容创作
content_maker=(
    "NickeManarin.ScreenToGif"                      # Gif 制作
)

# 其余的跨平台应用,厂商做好跨平台和云服务

# 社交聊天
chat_and_social_media=(
    "Tencent.WeChat"                                # 微信
    "Tencent.TIM"                                   # 简洁 QQ
    "Telegram.TelegramDesktop"                      # 小飞机
    "manually-RevokeMsgPatcher"                     # 微信 qq tim 多开+防撤回, https://github.com/huiyadanli/RevokeMsgPatcher?tab=readme-ov-file
)

ai_assitant=(
    # AI助手
    "ByteDance.Doubao"                              # 字节跳动旗下的豆包 AI 大模型助手, 免费
    "manually-通义千问"
    "manually-github-copilot"
)

# 浏览器
browsers=(
    "Mozilla.Firefox"                               # 主要看中他的 session container # winget install Mozilla.Firefox --locale en-US
    "Google.Chrome"                                 # 谷歌浏览器
    # "Microsoft.Edge"                                # 微软自家的浏览器，用来看 pdf, 采用的内核与谷歌一样，哪个好用，差不多，看个人习惯，移动端 edge 比较符合国人习惯
)


# 其他应用

# 网络
networking=(
    "2dust.v2rayN"                                  # 魔法上网
    # "ClashVergeRev.ClashVergeRev"                   # 魔法上网
    "Youqu.ToDesk"                                  # 远程桌面, 修电脑, 更好的内网穿透链接要收费
    "Parsec.Parsec"                                 # 串流远程桌面, 丝滑, 打游戏
    "LizardByte.Sunshine"                           # 串流工具
    "manually-gameviewer"                          # 网易出的串流工具
    # "ZeroTier.ZeroTierOne"                          # 用于建立虚拟局域网，方便远程 RDP 或者是同步软件同步数据
)

# 安全
security=(
    "Bitwarden.Bitwarden"                           # 密码即服务
    "msstore-XPDNH1FMW7NB40"                        # huorong 火绒安全软件,告别360,功能强大全方位防护,无广告,不弹窗,不流氓,无全家桶捆绑
    "KeePassXCTeam.KeePassXC"                       # 无服务端的 密码软件，可以通过同步软件同步到云端, bitwarden 有的功能都有了，就是界面没那么好看
)

# 美化
apperance_beautify=(
    "MacType.MacType"                               # 旨在为 Windows 提供类似 macOS 的字体渲染效果, 没感觉有啥区别
)

# 系统工具与瑞士军刀效率琐碎玩意
powertoys=(
    # 系统工具
    # "Eassos.DiskGenius"                             # 磁盘工具
    "Microsoft.Sysinternals.ProcessExplorer"        # 升级版专业版的任务管理器
    "gsass1.NTop"                                   # 命令行的任务管理器
    "ALCPU.CoreTemp"                                # CPU 监控
    # "Win10Debloat"
    "msstore-9NTXGKQ8P7N0"                          # Cross Device Experience, 链接手机
    "MilosParipovic.OneCommander"                   # 替代 Windows 自带的文件管理器, 高性能, 多选项卡, 多列布局(macos finder), 双窗格对照, 正则重命名等等
    "UderzoSoftware.SpaceSniffer"                   # 可视化 磁盘空间管理，C盘快满了, 怎么办呢
    "xanderfrangos.twinkletray"                     # 外接屏可以通过 Windows 来调整亮度, 将两者调整为同步亮度, 再打开 笔记本的自动调整亮度，完美。
    "manually-Piriform.CCleaner"                    # 清理注册表，文件查重
    "manually-TrafficMonitor"                       # 监控 cpu/gpu/网络等 usage, 温控信息, 置于任务栏中  # "https://github.com/zhongyang219/TrafficMonitor/releases/latest"



    # 效率玩意
    "voidtools.Everything"                          # everything 高性能,超快响应的 windows 文件搜索工具
    "Microsoft.PowerToys"                           # 瑞士军刀
    "PixPin.PixPin"                                 # 截图工具, 可以替代微信q 截图功能到OCR
    "AntibodySoftware.WizTree"                      # 类似于查找大文件，但更快速，找出，树状图显示，找出重复文件和大文件
    "Tencent.WeType"                                # 微信拼音
    # "Sogou.SogouInput"                              # 搜狗输入法, 搞得花里胡哨的, 广告多,微信更简单


    # 办公效率
    "Yuanli.uTools"                                 # 桌面级的工作流超级工具，按Alt+空格，连接 AI, 搜索引擎, 本地应用打开, 本地文件搜索.
    "7zip.7zip"                                     # 开源解压缩软件，支持多种格式, 平替 winrar
    "RARLab.WinRAR"                                 # winrar
    "hluk.CopyQ"                                    # 剪贴板工具
    "agalwood.Motrix"                               # 开源免费下载工具: 简单 小而美 但足够强大和全能，如此谬赞只因为现在的应用都在拼命卖广告割韭菜.
    "JGraph.Draw"                                   # draw.io 本地版.画图工具，开源免费强大，对于制作 PPT 的流程图 示意图绰绰有余, 无需登录，无广告，无流氓行为

    "AutoHotkey.AutoHotkey"                         # 自动化重复按键操作
    # 按键精灵
    "msstore-9PFN5K6QXT46"                          # onequick 自动化 Windows 的动作< 整理成高层任务式子命令
    "LiErHeXun.Quicker"                             # 同上, 点点点, 无需记住命令，鼠标点就完了。
    "manually-mykeymap"                                      # 基于 autohotkey, 经过仔细优化工作实际场景，来通过 GUI 的方式定义键盘映射，用键盘控制鼠标，符合国人需求, 中文界面 # https://xianyukang.com/MyKeymap.html # https://github.com/xianyukang/MyKeymap/releases/latest https://www.bilibili.com/video/BV1Sf4y1c7p8/?vd_source=4e89d319f42525ba93509e5455cb1cbf
    # wgestures                                     # 同上 鼠标手势 https://www.yingdev.com/projects/wgestures2
 
)

# 健康与健身
healthy_life=(
    "manually-https://musclewiki.com/"                       # web 应用
)

# 影音技术
audio_video_tech=(
    "Gyan.FFmpeg"                                     # 音视频编码和转码，非常强大
    "manually-Alternative-A2DP-Driver"                # windows 目前不支持 蓝牙高码率音频输出，安装该驱动可达到 双通道 24bit 96khz 采样, https://www.bluetoothgoodies.com/a2dp/
    # "msstore-9N0866FS04W8"                                  # Dolby Access, 淘宝 10块钱的杜比音效/视界激活码
    # "msstore-9n4wgh0z6vhq"                                  # hevc 8k 视频解码包,笔记本已经装好 来自设备制造商的视频扩展 hevc HEVC Video Extensions from Device Manufacturer, https://apps.microsoft.com/detail/9n4wgh0z6vhq?ocid=pdpshare&hl=en-us&gl=US
    # "msstore-9NMZLZ57R3T7"                                  # hevc 视频扩展 https://www.microsoft.com/store/productId/9NMZLZ57R3T7?ocid=pdpshare
    # "msstore-9pltg1lwphlf"                                  # Dolby Vision Extensions https://apps.microsoft.com/detail/9pltg1lwphlf?ocid=libraryshare&hl=en-us&gl=US
    # "msstore-9nvjqjbdkn97"                                  # Dolby Digital Plus decoder for PC OEMs  https://apps.microsoft.com/detail/9nvjqjbdkn97?ocid=libraryshare&hl=en-us&gl=US
)

# 编程开发
devtoys=(
    "Microsoft.VisualStudioCode"                    # 微软开发的热门的开源编程IDE
    "manually-vscode-gitlens-pro"                   # https://linux.do/t/topic/181333
    "Neovim.Neovim"                                 # 将 vim 搬到 Windows 上用, 用于偶尔的轻编辑, 重活还是让 vscode 和 其他 IDE 来吧
    # "Git.Git"                                       # 版本管理工具
    # "Cygwin.Cygwin"                                 # Windows 上的 unix like 终端, git bash, wsl1, wsl2, cygwin, MSYS2, nushell 讨论:https://cn.v2ex.com/t/1051792, 
    # 重点看看 cygwin, msys2, 用好 gui, shell 就放弃吧, 远程 ssh 处理一下文件就得了,
    # 建议通过 ssh 连接远程主机，并通过 share_folder 的方式搞搞。
    "WinSCP.WinSCP"                                 # 图形化的 SCP，通过 ssh 加密传输文件
    # "Microsoft.WindowsTerminal"                     # Windows 终端.
    # "Chocolatey.Chocolatey"                         # 另一个包管理利器, chocolatey.
    # shell tools set
    "JFLarvoire.Ag"                                 # silver searcher
    "voidtools.Everything.Cli"                      # everything cli
    # "Genymobile.scrcpy"                             # 电脑控制手机
    # "Google.PlatformTools"                          # adb 安卓手机调试工具
    "Python.Python.3.13"                            # python
    "IPIP.BestTrace"                                # 路由追踪
    "DevToys-app.DevToys"                           # 编程开发瑞士军刀, 不用再在网上找一些信不过的网页做啥 json 转换等等
    "manually-Axosoft.GitKraken"                    # 漂亮的 git 客户端， 再也不用傻傻搞不清楚了
    "manually-Telerik.Fiddler.Everywhere"           # Windows 抓包工具, 收费
    "manually-Termius.Termius"                      # ssh 连接工具, 其实用处有限, 配置好 shell 后在 powershell 一个命令就能连上了，为啥要 gui 管理啥呢。
    "manually-PremiumSoft.NavicatPremium"           # 数据库工具
    "manually-Nexttrace"                            # 路由追踪工具
    # "Postman.Postman"                               # Web API 开发必备
    "JetBrains.PyCharm.Professional"                # JB 的 pycharm, 强大 IDE
    "JetBrains.IntelliJIDEA.Ultimate"               # JB 的 java IDE
    "GitHub.cli"                                    # github cli
)

# 依赖
dependencies=(
    "OpenJS.NodeJS"                                 
)

# 部分 app 需要交互式安装点东西，例如 potplayer 需要安装额外的编解码器
interactive_install_apps=(
    "Daum.PotPlayer"                                # 目前近乎万能的播放器, 新版支持杜比视界, 见帖子汇总:https://v2ex.com/t/1023976
)

apps_groups=("co_workspace_anywhere" "netdisk" "co_workspace_anywhere_apps" "content_maker" "chat_and_social_media" "ai_assitant" "browsers" "networking" "security" "apperance_beautify" "powertoys" "healthy_life" "audio_video_tech" "devtoys" "dependencies" )
# apps_groups=("content_maker")
# apps_groups=("co_workspace_anywhere")
# apps_groups=("netdisk")
# apps_groups=("co_workspace_anywhere_apps")
# apps_groups=("chat_and_social_media")
# apps_groups=("ai_assitant")
# apps_groups=("browsers" "networking" "security")
# apps_groups=("apperance_beautify" "powertoys" "healthy_life" "audio_video_tech" "devtoys" "dependencies" )
