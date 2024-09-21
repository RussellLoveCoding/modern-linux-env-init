#!/bin/bash
set -e
source common.sh

installPVE() {
    # 更换非订阅源
    source /etc/os-release
    cp /etc/apt/sources.list.d/pve-no-subscription.list /etc/apt/sources.list.d/pve-no-subscription.list.bak
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/pve $VERSION_CODENAME pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list

    # 更换Debian系统源
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    sed -i 's|^deb http://ftp.debian.org|deb https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list
    sed -i 's|^deb http://security.debian.org|deb https://mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list

    # 更换LXC容器源
    cp /usr/share/perl5/PVE/APLInfo.pm /usr/share/perl5/PVE/APLInfo.pm_back
    sed -i 's|http://download.proxmox.com|https://mirrors.ustc.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm
    systemctl restart pvedaemon

    cp /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.bak
    if [ -f /etc/apt/sources.list.d/ceph.list ]; then CEPH_CODENAME=`ceph -v | grep ceph | awk '{print $(NF-1)}'`; source /etc/os-release; echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/ceph-$CEPH_CODENAME $VERSION_CODENAME no-subscription" > /etc/apt/sources.list.d/ceph.list; fi

    sed -rin 's~(.*)~# \1~g;' /etc/apt/sources.list.d/pve-enterprise.list
    # echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" >>/etc/apt/sources.list.d/pve-enterprise.list
    $upgrade
    apt-get install vim lrzsz unzip net-tools curl screen uuid-runtime sudo git -y
    apt-get install -y apt-transport-https ca-certificates  --fix-missing
    apt dist-upgrade -y

    # apt update && apt -y install git && git clone https://github.com/ivanhao/pvetools.git
    # cd pvetools
    # ./pvetools.sh

}

setup_hardware_passthrough() {
    echo 
    echoContent green "your /etc/default/grub setting as shown as following:"
    echo
    \grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub
    bak_content=`\grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub`

    echo
    echo "which provider are you CPU is? amd or intel, enter it"
    read provider
    if [ "$provider" == "intel" ]; then
        content_to_append="intel_iommu=on iommu=pt"
    else
        content_to_append="amd_iommu=on iommu=pt"
    fi

    # 检查是否已经存在硬件直通内容
    if ! grep -q "$content_to_append" /etc/default/grub; then
        sed -rin "s/(GRUB_CMDLINE_LINUX_DEFAULT\=\"quiet.*)\"$/\1 $content_to_append\"/p;"   /etc/default/grub
        echo "Hardware passthrough content appended. Please check it"
        \grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub
    else
        echo "Hardware passthrough content already exists."
    fi

    echo
    echo "Do you want to recover the original GRUB_CMDLINE_LINUX_DEFAULT line? (yes/no)"
    read recover
    if [ "$recover" == "yes" ]; then
        # 恢复原始内容
        sed -ri "s/(GRUB_CMDLINE_LINUX_DEFAULT=\".*\")/$bak_content/" /etc/default/grub
        echo "Original GRUB_CMDLINE_LINUX_DEFAULT line recovered."
        \grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub
    fi
}  


display_cpu_power_costing_temperature_etc_info_on_web_pabe() {
    # 一键给PVE增加温度和cpu频率显示，NVME，机械固态硬盘信息
    curl -Lf -o /tmp/temp.sh https://raw.githubusercontent.com/a904055262/PVE-manager-status/main/showtempcpufreq.sh  && chmod +x /tmp/temp.sh && /tmp/temp.sh remod
    # (curl -Lf -o /tmp/temp.sh https://raw.githubusercontent.com/a904055262/PVE-manager-status/main/showtempcpufreq.sh || curl -Lf -o /tmp/temp.sh https://ghproxy.com/https://raw.githubusercontent.com/a904055262/PVE-manager-status/main/showtempcpufreq.sh) && chmod +x /tmp/temp.sh && /tmp/temp.sh remod
    # 没有显示功耗的，请执行下面的命令安装依赖，请确保安装成功，就是最后的一行的输出，必须为 “成功!” 才表示安装成功了。
    apt update ; apt install linux-cpupower && modprobe msr && echo msr > /etc/modules-load.d/turbostat-msr.conf && chmod +s /usr/sbin/turbostat && echo 成功！
    # 如果你已经用别人的脚本之类的修改过页面，请先用下面命令先回复官方设置之后，才可以运行本脚本：
    apt update
    apt install pve-manager  proxmox-widget-toolkit  --reinstall
    rm -f /usr/share/perl5/PVE/API2/Nodes.pm*bak
    rm -f  /usr/share/pve-manager/js/pvemanagerlib.js*bak
    rm -f /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js*bak
}

vm_disk_backup_and_attach() {

    echo
    echo
    echo
    #echoContent green "cat /etc/pve/qemu-server"
    echoContent skyeBlue "which vm disk do you want to attach to vm, enter name, such as vm-102-disk-0"
    read disk_name
    echo
    echoContent skyeBlue "which vm do you want to attach the disk, enter id, such as 100"
    read vmid
    echo
    size=`pvesm list local-lvm |\grep $disk_name| awk '{print $4}'`
    size_gb=`echo "scale=2; $size/1024/1024/1024" | bc`
    disk_in_conf=`pvesm list local-lvm |\grep $disk_name| awk '{print "scsi0: "$1",ssd=1"}'`
    line="${disk_in_conf},size=${size_gb}GB"
    echo skyeBlue "add the folloing line to file /etc/pve/qemu-server/$vmid.conf"
    echo "then execute commadnd: systemctl restart pve-cluster"
    echo
    echo $line

    conf="agent: 1,fstrim_cloned_disks=1
boot: order=scsi0;ide2;net0
cores: 28
cpu: host
hotplug: disk,network,usb,memory,cpu
ide2: none,media=cdrom
memory: 16384
meta: creation-qemu=8.1.2,ctime=1726890461
name: homelab
net0: virtio=BC:24:11:52:72:18,bridge=vmbr0,firewall=1
numa: 1
ostype: l26
scsi0: local-lvm:vm-300-disk-0,size=100G,ssd=1
scsihw: virtio-scsi-single
smbios1: uuid=e84f20c9-0187-4a3e-b80a-dd20f6bbc828
sockets: 1
vmgenid: 4c1387d0-fcce-487f-a21d-6e53f2d42e65
"
    echo "$conf"
}

vm_disk_backup_and_attach
