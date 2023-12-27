
# vgpu 好像假如不执行一下以下的更新命令，重启后无法生效， windows 开不了机。
vgpu() {

    sudo tee /etc/systemd/system/update-grub-initramfs.service <<EOF
[Unit]
Description=Update GRUB and initramfs

[Service]
ExecStart=/bin/bash -c 'update-grub; update-initramfs -k all -u'

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl enable update-grub-initramfs
}
