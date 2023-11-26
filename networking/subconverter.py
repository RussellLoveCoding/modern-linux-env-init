import yaml
import requests
import base64

# 读取 Clash 配置文件
url = os.environ.get('SUB_URL')
response = requests.get(url)
resptext = response.text.replace('\t','')
clash_config = yaml.safe_load(resptext)

# 提取 proxies 节点信息
proxies = clash_config['proxies']

# 转换为 v2rayN 能读取的节点URL连接
v2rayn_links = []
for proxy in proxies:
    if proxy['type'] == 'vmess':
        # 构造 v2rayN 链接
        vmess_link = '{}:{}@{}:{}?alterId={}'.format(
            proxy['uuid'],
            proxy['cipher'],
            proxy['server'],
            proxy['port'],
            proxy['alterId'],
        )
        if 'network' in proxy:
            vmess_link = vmess_link + '&network=' + proxy['network']
        # Base64 编码
        vmess_link_encoded = base64.b64encode(vmess_link.encode()).decode()
        v2rayn_links.append('vmess://' + vmess_link_encoded)

# 输出 v2rayN 链接
for link in v2rayn_links:
    print(link)
