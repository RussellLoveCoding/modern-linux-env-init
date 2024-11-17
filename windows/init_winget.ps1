# 请用 admin 模式执行以下命令
# set_profile() {
#     mkdir -p "C:\Users\Public\Downloads\winget_cache"
#     # 这里会乱码
#     content=
# '
# [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# $env:WINGET_CACHE = "C:\Users\Public\Downloads\winget_cache"
# $env:WINGET_CACHE_FOLDER = "C:\Users\Public\Downloads\winget_cache"
# '
#     # 设置 utf-8
#     # echo '[Console]::OutputEncoding = [System.Text.Encoding]::UTF8' >> $PROFILE.AllUsersAllHosts
#     # winget 设置缓存
#     # echo '$env:WINGET_CACHE = "C:\Users\Public\Downloads\winget_cache"' >> $PROFILE.AllUsersAllHosts
# }

# install_choco() {
#     # 官方推荐的检测
#     if ((Get-ExecutionPolicy) -eq 'Restricted') {
#         Set-ExecutionPolicy AllSigned -Scope CurrentUser -Force
#         Set-ExecutionPolicy Bypass -Scope Process
#     }

#     # 官方一键安装脚本
#     Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#     # 配置 Chocolatey 软件安装默认位置, 软件安装包缓存
#     # mkdir -p D:\ChocolateyProgram\lib  
#     mkdir D:\ChocolateyCache
#     choco config set cacheLocation D:\ChocolateyCache\

#     # 验证安装包缓存位置配置正确
#     choco config get cacheLocation

#     # 设置 Choco 环境变量，使得默认安装位置为  D:\ChocolateyProgram
#     # sudo powershell -Command "[System.Environment]::SetEnvironmentVariable('ChocolateyInstall', 'D:\ChocolateyProgram', 'Machine')"

#     # 启动新的 powershell 检查 是否生效
#     # 需要新启动一个 powershell 
#     if ($env:ChocolateyInstall) {
#         Write-Output "ChocolateyInstall 环境变量设置为: $env:ChocolateyInstall"
#     } else {
#         Write-Output "ChocolateyInstall 环境变量未设置好."
#     }
# }


# 检查 WinGet 版本
$wingetVersion = (winget --version)
$versionPattern = '(\d+)\.(\d+)\.(\d+)'
if ($wingetVersion -match $versionPattern) {
    $majorVersion = [int]$matches[1]
    $minorVersion = [int]$matches[2]
}

# 替换 WinGet 源
if ($majorVersion -gt 1 -or ($majorVersion -eq 1 -and $minorVersion -ge 8)) {
    # WinGet >= 1.8
    winget source remove winget
    winget source add winget https://mirrors.ustc.edu.cn/winget-source --trust-level trusted
} else {
    # WinGet <= 1.7
    winget source remove winget
    winget source add winget https://mirrors.ustc.edu.cn/winget-source
}

# 检查是否出现 0x80073d1b 错误
try {
    winget source update
} catch {
    if ($_.Exception.Message -match "0x80073d1b") {
        Write-Host "出现 0x80073d1b : smartscreen reputation check failed. 错误，请检查网络连接或暂时关闭 SmartScreen。"
    } else {
        throw $_
    }
}

# 提供重置为官方地址的命令
Write-Host "如需重置为官方地址，执行以下命令即可："
Write-Host "winget source reset winget"