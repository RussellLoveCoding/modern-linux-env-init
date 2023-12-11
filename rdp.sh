remoteDesktop() {
    # 在 Ubuntu 源仓库有很多桌面环境供你选择。一个选择是安装 Gnome，它是 Ubuntu 20.04 的默认桌面环境。另外一个选项就是安装 xfce。它是快速，稳定，并且轻量的桌面环境，使得它成为远程服务器的理想桌面。
    # 运行下面任何一个命令去安装你选择的桌面环境：

    sudo apt update
    sudo apt install ubuntu-desktop

    sudo apt update
    sudo apt install xubuntu-desktop

    # 安装远程桌面协议服务器
    sudo apt install xrdp
    sudo adduser xrdp ssl-cert
    
    # 检查服务状态
    sudo systemctl status xrdp

    # 配置
    sudo cat /etc/xrdp/xrdp.ini
    
    # 配置防火墙
    sudo ufw allow from 192.168.0.0/16 to any port 3389
}

# 优化
# 1. 延迟, 使用 xcfe, lightdm 仍然有延迟
# 2. 使用原生 gdm ，桌面环境会休眠，就没法连上了。
optimize() {

}
