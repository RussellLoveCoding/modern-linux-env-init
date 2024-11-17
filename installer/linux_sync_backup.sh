#!/bin/bash

echo '
1. dev tool set
2. 
'

backup_root="."
home_backup_dir=$backup_root/home

disk_mount() {

    # nfs 挂载
    nfs_host_addr="192.168.2.3"
    nfs_path="/volume2/share_folder"
    local_mount_path="$HOME/nas"
    [ ! -d $local_mount_path ] && mkdir $local_mount_path
    echo "${nfs_host_addr}:${nfs_path} ${local_mount_path} nfs defaults 0 0" >> /etc/fstab
}


gitconfig() {
    cp $HOME/.gitconfig $home_backup_dir/gitconfig
}

# 包含隐私安全数据
sync_secret_info() {
    cp -r $HOME/.secrets $home_backup_dir/.secrets
}

# 包含隐私数据, 请谨慎公开
command_history() {

    # mysql 命令历史
    cp $HOME/.mysql_history $home_backup_dir/mysql_history

    # mycli
    cp $HOME/.mycli-history $home_backup_dir/mycli-history
    # cp $HOME/.myclirc $home_backup_dir/myclirc

    # shell 命令历史

    # python 命令历史
    cp $HOME/.python_history $home_backup_dir/python_history

    # mru 目录历史
    cp $HOME/.mru $home_backup_dir/mru
}

sync_p10zsh() {
    cp $HOME/.p10k.zsh $home_backup_dir/p10k.zsh
}