# 参考:
# 1. https://1024.day/d/35; 2. https://www.nodeseek.com/post-19427-1; 3.

general_setup() {
    # 拷贝osc52 方便复制粘贴
    scp ~/opt/bin/osc52 gcp-hk-debian:~/
    scp ~/opt/bin/osc52 gcp-hk-debian:~/
}

aws_ssh_via_cloudshell() {

    echo "please enter you private key"
    read privateKey
    echo "$privateKey"  mysin mysingaporekey.pem

    chmod 400 mysingaporekey.pem
    echo please enter your public ip or domain name of vps
    read hostname
    ssh -i "mysingaporekey.pem" admin@$hostname
}


sync_time() {
    # 同步时间
    sudo ntpdate ntp.aliyun.com
    # 设置时区
    # sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    # # 设置时间
    # sudo date -s "2020-01-01 00:00:00"
    # # 将当前的时间写入硬件时间
    # sudo hwclock -w
}

trace_route() {

    # 去程测试
    install_besttrace() {
        # https://www.ipip.net/product/client.html

        pushd /tmp
        curl -L "$URL" -o besttrace.zip
        unzip besttrace.zip -d besttrace
        sudo mv besttrace/* /usr/local/bin/
        popd
    }

    DATADIR="./data"

    # 测试 域名
    for i in assets.github.dev studious-zebra-v6v75j9wqvxv3w4gw.github.dev api.github.com api.githubcopilot.com assets.github.dev github.com raw.githubusercontent.com gist.github.com www.google.com; do
        sudo besttrace -m 50 $i >>route-to-$i.txt
    done

    # 测试 vps
    sudo besttrace -m 50 xxxxxxx >>route-to-aws-singapore.txt
    sudo besttrace -m 50 xxxxxxx >>route-to-gcp-hk.txt
    sudo besttrace -m 50 xxxxxxx >>route-to-azure-hk.txt
    sudo besttrace -m 50 xxxxxxx  >>route-to-digitalocean-singapore.txt

    # 整理格式
    [ -f trace-route-res.txt ] && \rm -f trace-route-res.txt
    for i in $(ls route-to-*.txt); do
        echo "\n\n\ndestination: $i\n" >>trace-route-res.txt
        echo "AS number,region,delay,ip" >>trace-route-res.txt
        cat $i |
            \sed -rn ' /\*$/d;s~^ ?[0-9]+ +~~g;/.*/p' |
            \sed -rn 's~(.*)+(\b[0-9]+.[0-9]+\b ms) +(\*|\bAS[0-9a-zA-Z]+\b) (.*)~\3===\1===\4===\2~g;/.*/p' |
            \sed -rn 's~ ~~g;s~,~-~g;s~===~,~g;/.*/p' |
            \awk -F, 'NR == 1 {print; next} !a[$1,$2]++ {print}' |
            \awk -F ',' 'BEGIN{OFS=","} {print $1,$3,$4,$2}' >>trace-route-res.txt
        echo "\n\n\n" >>trace-route-res.txt
    done

    pretty_output_file_1() {
        header=$(grep -m 1 -E 'Destination: .*' "$1")

        # Use sed to remove the header line from the file
        sed -i "/$(echo "$header" | sed 's/[][.*^$(){}?+|/\\]/\\&/g')/d" "$1"

        # Use awk to print the CSV content with pretty formatting and collapse long strings
        awk -F',' 'BEGIN {printf "%-15s%-50s%-10s%-15s\n", "AS number", "region", "delay", "ip"}
            {
                printf "%-15s%-50s%-10s%-15s\n", $1, $2, substr($3, 1, 10), substr($4, 1, 15)
            }' "$1"
    }

    pretty_output_file_2() {
        header=$(grep -m 1 -E 'Destination: .*' "$1")

        # Remove the header line from the file
        sed -i "/$(echo "$header" | sed 's/[][.*^$(){}?+|/\\]/\\&/g')/d" "$1"

        # Use awk to print the CSV content with pretty formatting and collapsing long strings
        awk -F',' -v OFS=',' 'BEGIN {printf "%-15s%-50s%-10s%-15s\n", "AS number", "region", "delay", "ip"}
            {
                if (length($1) > 15) $1 = substr($1, 1, 12) "...";
                if (length($2) > 50) $2 = substr($2, 1, 47) "...";
                if (length($3) > 10) $3 = substr($3, 1, 7) "...";
                if (length($4) > 15) $4 = substr($4, 1, 12) "...";

                printf "%-15s%-50s%-10s%-15s\n", $1, $2, $3, $4
            }' "$1"
    }
    pretty_output_file_1 trace-route-res.txt

    # 回程测试
    wget -N --no-check-certificate https://raw.githubusercontent.com/Chennhaoo/Shell_Bash/master/AutoTrace.sh && chmod +x AutoTrace.sh && bash AutoTrace.sh
    wget -qO- git.io/besttrace | bash
}

aws_setup() {
    sudo yum remove awscli
    pip uninstall awscli
    pushd /tmp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    popd
    # 同步时间，否则凭证会因为时间不同步而失效

    sync_time

    # 到 aws 控制头，点击右上角的用户名，选择“安全凭证”， 创建“访问密钥”并保存凭证，然后在本地执行下面的命令，
    # 输入 access_key_id, access secret key, region, output format, 其中 region 可以在 aws 控制台点击右上角的 “全球”
    # 查看不同 region 的 ID
    aws configure
    # 列出实例的关键信息
    aws ec2 describe-instances --query 'Reservations[].Instances[].{ID:InstanceId, Region:Placement.AvailabilityZone, State:State.Name, IP:PublicIpAddress}'

    aws ec2-instance-connect ssh --instance-id i-09982c25f78602558 --private-key-file ~/.ssh/mysingaporekey.pem

}

gcloud_setup() {
    # 参考 https://cloud.google.com/sdk/docs/install?hl=zh-cn 安装 gcloud
    # 中间可能要
    sudo apt update
    sudo apt-get install apt-transport-https ca-certificates gnupg curl sudo
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt-get update && sudo apt-get install google-cloud-cli
    # 连接实例
    gcloud compute ssh hk-instance-1
    # 列出实例
    gcloud compute instances list
    # 通过 gcloud 间接连接实例
    gcloud compute ssh instance-1 --tunnel-through-iap --zone=asia-east2-a

    # create an instance

    troubleshooting() {

    }

}

digitalocean_setup() {

    # 使用 doctl 与 kubectl 的集成需要 kube-config 个人文件接口。要启用它，请运行：
    sudo snap connect doctl:kube-config

    sudo snap install doctl

    # ssh 使用 doctl compute ssh 需要核心 ssh-keys 接口。要启用它，请运行：
    sudo snap connect doctl:ssh-keys :ssh-keys

    # 使用 doctl registry login 需要 dot-docker 个人文件接口。要启用它，请运行：
    sudo snap connect doctl:dot-docker

    # 输入 access token
    doctl auth init

    # 启动一个 droplet
    doctl compute droplet-action power-on <droplet-id>

    # 查看防火墙
    doctl compute firewall list --droplet-id 378534014

    # 创建一个实例
    doctl compute droplet create \
    --image ubuntu-20-04-x64 \
    --size s-1vcpu-1gb \
    --region sfo3 \
    --enable-monitoring \
    --enable-ipv6 \
    ubuntu-s-1vcpu-1gb-sfo3-01

}

modify_ssh_port() {
    # 修改 ssh 端口
    sudo sed -i 's/#Port 22/Port 12022/g' /etc/ssh/sshd_config
    sudo systemctl restart ssh.service
}

v2ray_agent_setup() {

    sudo passwd root

    # 一键搭建 reality 脚本
    wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
}



executing_command_via_cloud_shell() {
    #!/bin/bash
    # List of instance IDs in a file (one per line)

    # MY_AWS_USERNAME="hin2202"
    # aws ec2 describe-instances --query "Reservations[].Instances[?Tags[?Key=='CreatedBy' && Value=='$MY_AWS_USERNAME']].InstanceId" --output text

    INSTANCE_IDS_FILE="instance_ids.txt"
    # Script to execute on instances
    SCRIPT_FILE="mycommand.sh"

    tee $SCRIPT_FILE <<EOT
# command here
echo "Hello from instance $HOSTNAME"
EOT

    # AWS region
    AWS_REGION="ap-southeast-1b"

    # Loop through instance IDs and execute the script
    while IFS= read -r instance_id; do
        public_ip=$(aws ec2 describe-instances --region $AWS_REGION --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        ssh -i your-key.pem ec2-user@$public_ip "bash -s" <$SCRIPT_FILE
    done <"$INSTANCE_IDS_FILE"

}


ipv6_proxy_pool() {

    enable_ipv6_proxy() {

        # 需要添加路由
        # 此命令提示 Error: any valid prefix is expected rather than "2400:6180:0:d0/64"
        # ip route add local 2400:6180:0:d0/64 dev eth0
        
        ipv6_prefix=`ip a | sed -rn 's~.*inet6 (2.*)/[0-9]+ scope global .*~\1~p'`
        # 此时算一下前缀有多少位，再继续
        sudo ip route add local ffff:ffff:ffff::/96 dev ens4
        sysctl net.ipv6.ip_nonlocal_bind=1
        apt install ndppd
        sudo tee /etc/ndppd.conf << EOT
route-ttl 30000
proxy ens4 {
    router no
    timeout 500
    ttl 30000
    rule ffff:ffff:ffff::/96 {
        static
    }
}
EOT
        systemctl start ndppd
        
        # 2400:6180:0:d0::171:c001
        # 2400:6180:0:d0

        # 2400:6180:0:d0
         curl --interface ffff:ffff:ffff::/96 ipv6.ip.sb
        # curl --interface 2001:19f0:6001:48e4::1 ipv6.ip.sb
        # curl --interface 2001:19f0:6001:48e4::2 ipv6.ip.sb
    }

    init_rustc_env() {
        sudo apt install rustc cargo
    }

    disable_ipv6_proxy() {
        ip route del local ffff:ffff:ffff::/96 dev eth0
        sysctl net.ipv6.ip_nonlocal_bind=0
        apt remove ndppd
        systemctl stop ndppd
    }

}
