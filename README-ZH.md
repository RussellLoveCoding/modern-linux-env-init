GitHub Copilot: # 现代化开发环境初始化

此项目的目标是为开发设置一个现代化的Linux环境，包括一系列配置文件和脚本。

项目结构规范：
1. vscode-setting 包括

## 设置字体

此内容由power10k shell主题建议

微软的Windows Terminal（新事物）：打开设置（Ctrl+,），点击已选中的配置文件，位于配置文件或默认值下，点击外观并将字体设置为MesloLGS NF。

Visual Studio Code：打开文件→首选项→设置（PC）或代码→首选项→设置（Mac），在设置选项卡顶部的搜索框中输入terminal.integrated.fontFamily，并将下面的值设置为MesloLGS NF。参考此截图以查看它应该是什么样子，或查看此问题以获取额外信息。

## Windows

要将Windows Terminal配置为GitHub Dark Dimmed主题，您需要修改Windows Terminal的设置文件。以下是步骤：

1. 打开Windows Terminal。

2. 点击右上角的下拉箭头并选择“设置”。这将打开Windows Terminal的设置文件（一个JSON文件）。

3. 在此JSON文件中，找到一个名为“schemes”的数组。此数组中的每个对象都代表一个颜色方案。

4. 在“schemes”数组中，添加一个新对象，将其设置为GitHub的Dark Dimmed主题的颜色。例如：

```json
{
    "name": "GitHub Dark Dimmed",
    "background": "#22272E",
    "foreground": "#ADBAC7",
    "black": "#22272E",
    "blue": "#539BF5",
    "brightBlack": "#636E7B",
    "brightBlue": "#539BF5",
    "brightCyan": "#6BCAD1",
    "brightGreen": "#6BC46D",
    "brightPurple": "#D16D9E",
    "brightRed": "#F47067",
    "brightWhite": "#F0F0F0",
    "brightYellow": "#E5C07B",
    "cyan": "#6BCAD1",
    "green": "#6BC46D",
    "purple": "#D16D9E",
    "red": "#F47067",
    "white": "#ADBAC7",
    "yellow": "#E5C07B"
}
```

5. 在“profiles”对象的“defaultProfile”对象或您想要修改的特定配置中，将“colorScheme”属性设置为您刚添加的颜色方案的名称。例如：

```json
{
    "guid": "{07b52e3e-de2c-5db4-bd2d-ba144ed6c273}",
    "hidden": false,
    "name": "Windows PowerShell",
    "source": "Windows.Terminal.PowershellCore",
    "colorScheme": "GitHub Dark Dimmed"
}
```

6. 保存并关闭设置文件。Windows Terminal将自动应用新的设置。

注意：此颜色方案是根据GitHub的Dark Dimmed主题的颜色设置的，可能并不完全相同。您可以根据自己的喜好调整颜色。

## vscode

## vim设置

### 剪贴板共享规范

我的环境：远程主机操作系统是Linux，本地主机操作系统是Windows

如何在几个环境实例之间共享剪贴板，包括
1. 本地主机，
2. 远程主机的tmux环境
3. 本地主机的neovim或vim
3. 远程主机的neovim或vim。

这使我可以做以下事情：
1. 在本地主机中简单地：在neovim/vim实例和系统剪贴板实例之间复制/粘贴，这意味着我可以在vim中按`p`命令从Windows剪贴板粘贴内容，并使用yank命令`y`从neovim/vim中的内容粘贴到Windows11应用程序的编辑器中。
2. 在远程主机中简单地：在neovim/vim和tmux窗口之间复制/粘贴，这意味着我可以使用`y`（yank）命令从vim中粘贴内容到tmux窗口，使用`prefix+]`命令，并使用`p`命令从tmux窗口（首先通过`prefix+[`命令进入视觉模式，然后选择文本，最后按`enter`命令复制）粘贴到vim/neovim中。
3. 跨主机共享：
    - 从本地主机到远程主机的方向：这主要是关注从本地系统剪贴板（即Windows）粘贴内容，并使用`p`命令将其粘贴到neovim/vim中，因为我们可以轻松地使用`ctrl+v`或`ctrl+shift+v`命令将内容粘贴到远程主机的tmux或shell或其他编辑器中。
    - 从远程主机到本地主机的方向：从远程主机的neovim/vim或tmux窗口复制内容，然后本地主机的系统剪贴板可以共享读取这些内容，所以我可以在Windows的任何地方使用`ctrl+v`粘贴。

现在我知道有一种叫做“OSC52”的方法，可以实现从远程主机的tmux和vim到本地主机的复制。