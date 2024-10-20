if ((Get-ExecutionPolicy) -eq 'Restricted') {
    Set-ExecutionPolicy AllSigned -Scope CurrentUser -Force
    Set-ExecutionPolicy Bypass -Scope Process
}

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 配置 Chocolatey 软件安装默认位置, 软件安装包缓存
# mkdir -p D:\ChocolateyProgram\lib  
mkdir D:\ChocolateyCache
choco config set cacheLocation D:\ChocolateyCache\

# 验证安装包缓存位置配置正确
choco config get cacheLocation

# 设置 Choco 环境变量，使得默认安装位置为  D:\ChocolateyProgram
# sudo powershell -Command "[System.Environment]::SetEnvironmentVariable('ChocolateyInstall', 'D:\ChocolateyProgram', 'Machine')"

# 启动新的 powershell 检查 是否生效
# 需要新启动一个 powershell 
if ($env:ChocolateyInstall) {
    Write-Output "ChocolateyInstall 环境变量设置为: $env:ChocolateyInstall"
} else {
    Write-Output "ChocolateyInstall 环境变量未设置好."
}

# 这里安装目录中的空格会导致最终安装在 `D:\Program` 该目录下，所以不能又空格
# choco install vscode --install-arguments="'/DIR=D:\Program Files\VSCode'" --params "/NoContextMenuFiles /NoContextMenuFolders"
# 以下命令会将 vscode 文件都安装在 VSCode
# choco install vscode --install-arguments="'/DIR=D:\Program_Files\VSCode'" --params "/NoContextMenuFiles /NoContextMenuFolders"

# 全部默认安装到C盘
# 编程开发
choco install vscode  neovim  git  gh  ag  httpie  cygwin -y
# 依赖
choco install  nodejs -y
# 浏览器
choco install firefox googlechrome -y
# 影音娱乐
choco install  potplayer netease-cloudmusic  mpv -y
# 办公效率
choco install   bitwarden   7zip  typora -y
# 系统工具
choco install  ccleaner synologydrive everything  synology-activebackup-for-business-agent   -y
# 社交聊天 暂时会出错
choco install telegram -y

# 失败 utools wechat tim typora parsecyuanliao-utools

# cygwin rsync 安装
curl -O https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
install apt-cyg /bin
chmod +x /bin/apt-cyg

echo '打开cygwin的安装文件，继续安装两个包: lynx, wget ，安装好以后, 将 cygwin 的 bin 目录添加到系统的环境变量 PATH 中'