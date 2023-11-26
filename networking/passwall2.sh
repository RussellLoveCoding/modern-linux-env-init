echo 
echo now, you have to do the following steps to correctly configure passwall2
echo '
1. run command to start subconverter as a container in openwrt `docker run -d --restart=always -p 25500:25500 tindy2013/subconverter:latest`
2. replace your_subscription_url with you subscription url, then execute the following command to get the subscription url, and then place it inton passwall2 corresponding location.
export SUB_URL=https://your_subscription_url && echo http://127.0.0.1:25500/sub\?target\=clash\&url\=`echo "${SUB_URL}" | python -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read().strip()))"`'
