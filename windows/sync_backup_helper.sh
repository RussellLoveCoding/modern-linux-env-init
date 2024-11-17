#!/bin/bash

# 自动搜集 windows 上应用配置和数据文件夹，备份到指定目录
set -e

command_exists() {
    command -v "$@" 1>/dev/null 2>&1
}

# 显示帮助信息
show_help() {
    echo "Usage: compress_folders [options]"
    echo "Options:"
    echo "  -d DIR        Specify the base directory to compress (required)"
    echo "  -p PASSWORD   Specify the encryption password (optional)"
    echo "  -e PATTERN    Specify the pattern for folders to encrypt (default: 'secret')"
    echo "  -h            Show this help message"
    exit 0
}

# 定义压缩函数
compress_folders() {
    # 压缩词典包
    ls |sed -rn 's~(.*)~7z a -tzip -mx=9 -mmt "../../../GD-词典-压缩包//content/主词典库(英英英汉)/\1.zip" "\1"~g;/.*/p;' | bash   
}

# 收集并压缩应用配置
# 这里在压缩过程中会有 文件被占用, 需要用到卷影复制技术, 但是压缩的话好像
# 全使用 linux 风格路径， 需要用到再用 
app_config_collector() {


    # dst_root_dir=$1


    # apps=`echo "$apps_configs" | awk -F, '{print $1}'`
    # ehco "即将收集如下应用数据"
    # echo apps
    # for app in $apps; do
    #     echo "正在收集 $app 配置文件"
    #     path=`echo "$apps_configs" | grep "$app" | awk -F, '{print $2}'`
    #     base_name=`basename $path`
    #     7z a -tzip -mx=5 -mmt   ${target_dir}/${base_name}.zip $path
    # done

    echo 
    echo 
    echo "本备份程序包括三项内容: 
1. C:\Users\user\AppData\Roaming, 和 %user%\Documents, 
2. 一些应用的配置文件, 如 vscode, winget, navicat, ssh, 等
3. 指导你进行不能自动化的手动备份

在备份前, 请尽可能地关闭所有应用, 以免部分应用配置因为程序占用而无法备份

"

    command_exists rar || {
        echo "rar 命令不存在, 请先安装 rar"
        exit 1
    }

    # 备份 roaming, 和 documents 的数据
    echo 
    read -p "按任意键继续, 按 Ctrl+C 取消" -n 1 -r
    echo
    read -p "请输入压缩密码: " -s password
    echo
    echo "正在备份 AppData/Roaming 目录 和  user/Documents 目录"
    echo
    start_time=$(date +%s)

    user=$(whoami)
    tmp_dst_root_dir="C:\\Users\\${user}\\tmp_backup"
    outputlog="/cygdrive/c/Users/${user}/sync_backup.output.log"
    [ -f $outputlog ] && rm $outputlog
    [ -d $tmpBackupPath ]  && rm -rf $tmpBackupPath
    [ ! -d $tmpBackupPath ] && mkdir $tmpBackupPath

    roamingSrcDir="C:\\Users\\${user}\\AppData\\Roaming"
    roamingDstDir="${tmp_dst_root_dir}\\Roaming"

    [ ! -d $roamingDstDir ] && mkdir -p $roamingDstDir

    # 压缩参数: -idn 禁止输出逐个文件的压缩信息, -idc 不显示版权信息, 
    # -m0 为压缩程度为0 不压缩仅仅打包, -mt 为使用多线程压缩利用多核性能, -hp 是加密同时加密文件名, 
    # -rr5%  为带有5%的冗余记录以便于修复损坏的压缩包, 
    threads_num=$(grep -c ^processor /proc/cpuinfo)
    cd ${roamingSrcDir}
    echo total $(ls $roamingSrcDir|ag -iv '^code$|^mozilla$'|wc -l) dir in roaming to backup
    ls $roamingSrcDir | while read i
    do
        if echo "$i" | \grep -qiE  "^Code$|^Mozilla$"; then
            continue
        fi
        # 忽略一些又大胆没有的东西, 如缓存, 二进制文件, 日志, 插件.
        rar a -rr5% -idn -idc -m0 -hp${password} \
	        -xIDM\\DwnlData -xTencent\\Logs -xobsidian\\Cache\\Cache_Data \
            -xbaidu\\BaiduNetdisk\\module -x*.exe -x*Msixbundle -x*Appx -x*.dll -x*logs -x*Logs -x*.log -x*skin \
            -xlx-music-desktop\\Partitions\\win-main\\Cache -xkingsoft\\wps\\addons \
            -x"Microsoft\\Windows\\Start Menu\\Programs" -xTencent\\WeChat\\XPlugin \
            "${roamingDstDir}\\${i}.rar" "${i}"  | iconv -f GBK -t UTF-8 >> $outputlog 2>&1
    done

    cd /cygdrive/c/Users/${user}
    rar a -rr5% -idn -idc -m3  -hp${password} ${tmp_dst_root_dir}\\Documents.rar Documents  | iconv -f GBK -t UTF-8 >> $outputlog 2>&1

    cd $tmp_dst_root_dir\\Roaming
    ls ./*.rar | while read i
    do
	rar t -hp${password} "$i" | iconv -f GBK -t UTF-8 >> $outputlog 2>&1  
    done
    rar t -hp${password} $tmp_dst_root_dir\\Documents.rar  | iconv -f GBK -t UTF-8 >> $outputlog 2>&1  


    echo
    echo "文件备份在 $tmp_dst_root_dir 目录下"

    echo "
请使用如下命令检查有什么备份失败的,或者警告事项

ag -v  --nonumber  '注册|版权|正在|^$|完成|正常|OK|%' $outputlog

如果是普通的警告, 无法打开文件, 一般不用管, 因为是应用正在打开,并且占用文件, 无法备份
"

    # 备份 vscode, winget, ssh 配置
    echo
    echo "开始收集可以收集的应用配置"
    cp "/cygdrive/c/Users/${user}/AppData/Roaming/Code/User/settings.json" $(cygpath -p tmp_dst_root_dir)/vscode_settings.json
    cp $(cygpath -p $(winget settings export | jq . | ag usersettings | ag 'C:[^"]+' -o)) $(cygpath -p tmp_dst_root_dir)/winget_settings.json

    end_time=$(date +%s)
    elapsed_time=$((end_time - start_time))
    echo "总耗时: $elapsed_time 秒"
}

# 调用压缩函数
app_config_collector 
