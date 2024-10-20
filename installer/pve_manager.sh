#!/bin/bash
set -e
source common.sh

pve_menu() {

    # 1. 一键换源(ustc), 包括 pve, debian, ceph, lxc容器, 去掉 企业订阅提示, 企业源的错误提示
    # 2. 配置暗黑主题
    # 3. 修改 pve 网页概要显示信息，增加 CPU及线程频率、CPU及核心、主板等工作状态及温度，风扇转速，NVME及机械硬盘的型号、容量、温度、通电时间、IO状态
    # 4. 开启硬件直通
    # 5. 开启显卡直通， 安装
    # 6. 交互式 安装 iStoreOS 系统
    # 7. 交互式 安装 ubuntu 系统, 无人值守(请填写好配置文件)
    # 8. 交互式 安装 windows 10 ltsc 系统
    # 9. 交互式 安装 synology 黑群晖 系统
    # 10. 一键恢复 备份镜像 系统
    # 恢复所有软件源文件

    echo
}

install_synology() {
    synouser --setpw root password
}

install_ubuntu_server() {
    sudo apt-get update
    sudo apt-get install qemu-guest-agent
    sudo systemctl start qemu-guest-agent
    sudo systemctl enable qemu-guest-agent

    apt install -y linux-image-6.5.0-35-generic linux-headers-6.5.0-35-generic
    apt install -y "build-*" "dkms"
}

disable_unnecessary_service_win() {
    # Intel(R) SUR QC Software Asset Manager
    # windows antimalware difender
    # inter system usage report service
    echo
}

install_win10_ltsc() {
    # 不要开 内存和cpu的热插拔
    echoContent green "请准备好你的镜像并上传到此目录 /var/lib/vz/template/iso"
    # wget -P /var/lib/vz/template/iso https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
    # wget -P /var/lib/vz/template/iso https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

    vm_conf="
bios: ovmf # BIOS
efidisk0: local-lvm:vm-104-disk-0,efitype=4m,pre-enrolled-keys=1,size=4M # EFI磁盘 
sockets: 1 # CPU 插槽，一个 CPU, 多个核心
cores: 4 # 给最大的核心数了
boot: order=scsi0 默认
cpu: host # 必须的选择 host
hostpci0: 0000:00:02.1,pcie=1,x-vga=1 # 显卡直通, 注意，在 web 界面添加 pci 显卡设备时，保存后会自动保存为 00:02.0 物理显卡本体，导致 vgpu 失效，但是可以修改 这里的文件, 直通 02.1
hostpci1: 0000:00:1f.3,pcie=1 # 声卡, 但是 串流好像依然不管用, 需要加个虚拟声卡
ide0: local:iso/virtio-win.iso,media=cdrom,size=708140K # 虚拟驱动，必备
lock: backup
machine: pc-q35-8.1 # 机型选择 q35, 也是必须，后面的参数是默认
memory: 8192 # 8G内存
meta: creation-qemu=8.1.5,ctime=1727107875
name: win10-2021-ltsc # 名字自选
net0: virtio=BC:24:11:B4:F6:ED,bridge=vmbr0,firewall=1 # 网卡 默认即可
numa: 0 # 这里是开启 cpu, 内存 热插拔的必备参数，但是这里设置了，一开始安装 windows 会提示错误，而且不确定是否影响 vgpu 的直通，所以不设置了, 也不需要热插拔
ostype: win10 # 镜像是 win10-2021-ltsc 所以选择这个
scsi0: local-lvm:vm-104-disk-1,iothread=1,size=128G,ssd=1 # 系统盘，给大一点，因为安装 win10后，更新完都占 30B的空间
scsihw: virtio-scsi-single # 硬盘总线方式，默认
smbios1: uuid=885e6244-3277-42fe-982c-8ebb6dd397e3 # 这些是自动生成的
vmgenid: d1989818-048f-4da2-9db0-1c5e9a1f9f9c
"

}

install_istoreos() {
    # credit: https://blog.welain.com/archives/183/

    # 填写你的 VMID
    VMID=100
    URL="https://fw.koolcenter.com/iStoreOS/x86_64/"

    # 获取网页内容并提取最新的镜像文件链接
    LATEST_IMG=$(wget -qO- "$URL" | grep -oP 'istoreos-[0-9.]+-[0-9]+-x86-64-squashfs-combined.img.gz' | sort -V | tail -n 1)

    # 检查是否找到最新的镜像文件
    if [ -z "$LATEST_IMG" ]; then
        echo "未找到最新的镜像文件。"
    fi

    DOWNLOAD_URL="https://fw0.koolcenter.com/iStoreOS/x86_64/$LATEST_IMG"

    # 下载最新的镜像文件
    cd /var/lib/vz/template/iso
    wget -q --show-progress --max-redirect=5 "$DOWNLOAD_URL"
    gzip -d "$LATEST_IMG"
    IMG_NAME=$(echo "$LATEST_IMG"|\sed -rn 's~.gz~~g;/.*/p')
    qm importdisk $VMID "/var/lib/vz/template/iso/$IMG_NAME" local-lvm

    # 安装 qemu-guest-agent.

    # 上游路由器 LAN 口所属 IP 网段: 192.168.100.0/24

    # pve: eth1, virtio1, virtio2
    #     - 上游路由器 LAN 口 <----> PVE eth1 管理口,
    #     - PVE-virtio1 bridge <----> eth1 管理口, PVE-virtio1 IP 为 192.168.100.x
    #     - PVE-virtio2 bridge <-----> VM_router_istoreos-virtio2, PVE-virtio2 IP 为 192.168.2.x

    # VM_router_istoreos: virtio1(WAN) , virtio2(LAN) , eth2(LAN) , eth3(LAN) , eth4(LAN)
    #     - VM_router_istoreos-virtio1 bridged <-----> PVE-virtio1, VM_router_istoreos-virtio1 IP 为 192.168.100.x
    #     - virtio2 <-----> PVE-virtio2, VM_router_istoreos-virtio2 IP 为 192.168.2.1, 也就是 istoreOS 路由器新建一个子网 192.168.2.0/24
    #     - eth2-4 <--------> other downstream devices

    # VM_ubuntu: virtio1
    #     - vm_ubuntu-virtio1 <------> PVE-virtio2

}

install_discord_dark_theme() {
    # credit https://github.com/Weilbyte/PVEDiscordDark
    bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh) install
}

uninstall_discord_dark_theme() {
    echo
}

hdmi_passthrough() {
    echo
}

setup_SR_IOV() {
    lscpu | \grep -qEi 'vendor.*intel' || {
        echoContent red "只支持 Intel CPU"
        echoContent red "Only support Intel CPU"
        return 1
    }

    echoContent red "
警告: 这是一个高度实验性的项目，你应该知道自己正在干什么才用它
你需要在 Host 和 guest 系统中都安装 dkms 模块

本安装过程将需要多次重启
"
    echoContent red "
This package is highly experimental, you should only use it when you know what you are doing.
You need to install this dkms module in both host and guest!
This installtion process needs you machine reboot multitimes.
"
    # 升级内核、headers和firmware
    apt install -y pve-headers-$(uname -r) proxmox-kernel-$(uname -r)
    # install some tools.
    apt install -y "build-*" "dkms"

    [ ! -d "$HOME/tmp" ] && mkdir -p "$HOME/tmp"
    pushd $HOME/tmp
    git clone https://github.com/strongtz/i915-sriov-dkms.git
    cd i915-sriov-dkms
    dkms add .
    echoContent blue "截止本仓库版本 2024.09.21, 已经测试好内核的版本包括: 6.5 and 6.8"
    apt install pv -y 1>/dev/null
    command_exists pv && {
        echoContent green "开始安装 i915-sriov-dkms 模块"
        dkms install -m i915-sriov-dkms -v $(cat VERSION) --force | pv -l -s $(wc -l < <(dkms status i915-sriov-dkms | grep -o 'installing' | wc -l))
        # cat VERSION | pv -qL 10 | xargs -I {} dkms install -m i915-sriov-dkms -v {} --force
    }

    # check installation
    echoContent green "检查安装结果"
    installation_res=$(dkms status)
    succ_info="i915-sriov-dkms.*$(cat VERSION).*$(uname -r).*installed"

    if echo "$installation_res" | \grep -qE "$succ_info"; then
        echo "安装成功"
    else
        echo "安装失败"
    fi

    # 辅助检查安装结果命令: modinfo i915 | \grep --color vf

    # in order to enable the VFs, a sysfs attribute must be set. Install sysfsutils, then do echo
    apt install -y sysfsutils
    if [ $(lspci | \grep VGA | wc -l) -eq 1 ]; then
        gpu_id=$(lspci | \grep VGA | awk '{print $1}' | \grep -Eio '[0-9]{2}:[0-9]{2}')
    else
        echo '请通过 命令 `lspci | \grep VGA` 查看你的 iGPU 所在的 PCIe 总线'
        read -p "请输入你的 gpu pci 设备的编号: " gpu_id
        to find the PCIe bus your iGPU is on
    fi

    echo "你希望 核显gpu 虚拟出多少个 vgpu, 1个性能最强，7个最低, 可选数量: 1-7"
    read -r divided_vgpu_cnt
    if ! \grep -qEi "devices/pci0000:00/0000:${gpu_id}.0/sriov_numvfs" /etc/sysfs.conf; then
        echo "devices/pci0000:00/0000:${gpu_id}.0/sriov_numvfs = ${divided_vgpu_cnt}" >/etc/sysfs.conf
    fi

    PARAM_IOMMU_ON_INTEL="intel_iommu=on"
    PARAM_IOMMU_PT="iommu=pt"
    PARAM_I915_VGPU="i915.enable_guc=3 i915.max_vfs=7"
    #  the kernel commandline needs to be adjusted: nano /etc/default/grub and change GRUB_CMDLINE_LINUX_DEFAULT to intel_iommu=on i915.enable_guc=3 i915.max_vfs=7, or add to it if you have other arguments there already.
    if ! \grep -qEi "^GRUB_CMDLINE_LINUX_DEFAULT.*${PARAM_IOMMU_ON_INTEL}" /etc/default/grub; then
        \sed -rin "s~(^GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*)\"~\1 ${PARAM_IOMMU_ON_INTEL}\"~g;" /etc/default/grub
    fi
    if ! \grep -qEi "^GRUB_CMDLINE_LINUX_DEFAULT.*${PARAM_I915_VGPU}" /etc/default/grub; then
        \sed -rin "s~(^GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*)\"~\1 ${PARAM_I915_VGPU}\"~g;" /etc/default/grub
    fi
    if ! \grep -qEi "^GRUB_CMDLINE_LINUX_DEFAULT.*${PARAM_IOMMU_PT}" /etc/default/grub; then
        \sed -rin "s~(^GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*)\"~\1 ${PARAM_IOMMU_PT}\"~g;" /etc/default/grub
    fi

    PARAM_BLACK_LIST="options vfio_iommu_type1 allow_unsafe_interrupts=1"
    if ! \grep -iq "^${PARAM_BLACK_LIST}" /etc/modprobe.d/pve-blacklist.conf; then
        echo "${PARAM_BLACK_LIST}" >>/etc/modprobe.d/pve-blacklist.conf
    fi

    VFIO_PATTERN="vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd"

    # 定义文件路径
    MODULE_FILE="/etc/modules"
    (awk 'BEGIN{RS=""; FS="\n"} /vfio\nvfio_iommu_type1\nvfio_pci\nvfio_virqfd/ {found=1} END{if (found) print "yes"; else print "no"}' $MODULE_FILE | \grep -q yes) || echo "$VFIO_PATTERN" >>$MODULE_FILE

    update-grub
    update-initramfs -u
    update-initramfs -u -k all
    update-pciids

    echoContent red "即将重启，请确保保存好相关资料。"
    echoContent red "立即重启请输入 Y/y，稍后手动重启请输入 N/n"
    read -r isreboot
    case "$isreboot" in
    [Yy]*)
        echo "系统即将重启..."
        reboot
        ;;
    [Nn]*)
        echo "请稍后手动重启系统。"
        ;;
    *)
        echo "无效的输入，请输入 Y/y 或 N/n。"
        ;;
    esac
}

# 撤销上述步骤的影响
undo_side_effect_sr_iov() {
    # dkms remove -m i915-sriov-dkms -v 6.1
    # dkms install -m i915-sriov-dkms -v 6.1

    apt autoremove -y "pve-headers-$(uname -r)" "proxmox-kernel-$(uname -r)" "build-*" "dkms" "pv" "sysfsutils"

    for dir in /var/lib/dkms/i915-sriov-dkms*; do
        rm -rf ${dir}
    done

    for dir in /usr/src/i915-sriov-dkms*; do
        rm -rf ${dir}
    done

    sed -rin 's~ i915.enable_guc\=3 i915.max_vfs\=7~~g;' /etc/default/grub

}

installPVE() {
    # 更换非订阅源
    source /etc/os-release
    cp /etc/apt/sources.list.d/pve-no-subscription.list /etc/apt/sources.list.d/pve-no-subscription.list.bak
    echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/pve $VERSION_CODENAME pve-no-subscription" >/etc/apt/sources.list.d/pve-no-subscription.list

    # 更换Debian系统源
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    sed -i 's|^deb http://ftp.debian.org|deb https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list
    sed -i 's|^deb http://security.debian.org|deb https://mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list

    # 更换LXC容器源
    cp /usr/share/perl5/PVE/APLInfo.pm /usr/share/perl5/PVE/APLInfo.pm_back
    sed -i 's|http://download.proxmox.com|https://mirrors.ustc.edu.cn/proxmox|g' /usr/share/perl5/PVE/APLInfo.pm
    systemctl restart pvedaemon

    cp /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.bak
    if [ -f /etc/apt/sources.list.d/ceph.list ]; then
        CEPH_CODENAME=$(ceph -v | grep ceph | awk '{print $(NF-1)}')
        source /etc/os-release
        echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/ceph-$CEPH_CODENAME $VERSION_CODENAME no-subscription" >/etc/apt/sources.list.d/ceph.list
    fi

    sed -rin 's~(.*)~# \1~g;' /etc/apt/sources.list.d/pve-enterprise.list
    # echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" >>/etc/apt/sources.list.d/pve-enterprise.list
    $upgrade
    apt-get install vim lrzsz unzip net-tools curl screen uuid-runtime sudo git -y
    apt-get install -y apt-transport-https ca-certificates --fix-missing
    apt update
    apt dist-upgrade -y

    # apt update && apt -y install git && git clone https://github.com/ivanhao/pvetools.git
    # cd pvetools
    # ./pvetools.sh

}

display_cpu_power_costing_temperature_etc_info_on_web_pabe() {
    # 一键给PVE增加温度和cpu频率显示，NVME，机械固态硬盘信息
    curl -Lf -o /tmp/temp.sh https://raw.githubusercontent.com/a904055262/PVE-manager-status/main/showtempcpufreq.sh && chmod +x /tmp/temp.sh && /tmp/temp.sh remod
    # (curl -Lf -o /tmp/temp.sh https://raw.githubusercontent.com/a904055262/PVE-manager-status/main/showtempcpufreq.sh || curl -Lf -o /tmp/temp.sh https://ghproxy.com/https://raw.githubusercontent.com/a904055262/PVE-manager-status/main/showtempcpufreq.sh) && chmod +x /tmp/temp.sh && /tmp/temp.sh remod
    # 没有显示功耗的，请执行下面的命令安装依赖，请确保安装成功，就是最后的一行的输出，必须为 “成功!” 才表示安装成功了。
    apt update
    apt install linux-cpupower && modprobe msr && echo msr >/etc/modules-load.d/turbostat-msr.conf && chmod +s /usr/sbin/turbostat && echo 成功！
    # 如果你已经用别人的脚本之类的修改过页面，请先用下面命令先回复官方设置之后，才可以运行本脚本：
    apt update
    apt install pve-manager proxmox-widget-toolkit --reinstall
    rm -f /usr/share/perl5/PVE/API2/Nodes.pm*bak
    rm -f /usr/share/pve-manager/js/pvemanagerlib.js*bak
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
    size=$(pvesm list local-lvm | \grep $disk_name | awk '{print $4}')
    size_gb=$(echo "scale=2; $size/1024/1024/1024" | bc)
    disk_in_conf=$(pvesm list local-lvm | \grep $disk_name | awk '{print "scsi0: "$1",ssd=1"}')
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
