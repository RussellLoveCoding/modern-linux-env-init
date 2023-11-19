# Modern Development Environment Initialization

[简体中文](./README-ZH.md)

This project is to setup a modern linux environment for development, includign
series of configuration file and scripts.

project structure specifications:
1. vscode-setting includes 

## setting up font


this content is suggested by power10k shell theme

Windows Terminal by Microsoft (the new thing): Open Settings (Ctrl+,), click
either on the selected profile under Profiles or on Defaults, click Appearance
and set Font face to MesloLGS NF.

Visual Studio Code: Open File → Preferences → Settings (PC) or Code →
Preferences → Settings (Mac), enter terminal.integrated.fontFamily in the search
box at the top of Settings tab and set the value below to MesloLGS NF. Consult
this screenshot to see how it should look like or see this issue for extra
information.

## Windows

To configure Windows Terminal to the GitHub Dark Dimmed theme, you need to modify the settings file of Windows Terminal. Here are the steps:


1. Open Windows Terminal.

2. Click on the dropdown arrow in the upper right corner and select "Settings". This will open the settings file (a JSON file) of Windows Terminal.

3. In this JSON file, find an array named "schemes". Each object in this array represents a color scheme.

4. In the "schemes" array, add a new object, set it to the colors of GitHub's Dark Dimmed theme. For example:

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

5. In the "profiles" object's "defaultProfile" object or the specific configuration you want to modify, set the "colorScheme" attribute to the name of the color scheme you just added. For example:

```json
{
    "guid": "{07b52e3e-de2c-5db4-bd2d-ba144ed6c273}",
    "hidden": false,
    "name": "Windows PowerShell",
    "source": "Windows.Terminal.PowershellCore",
    "colorScheme": "GitHub Dark Dimmed"
}
```

6. Save and close the settings file. Windows Terminal will automatically apply the new settings.

Note: This color scheme is set according to the colors of GitHub's Dark Dimmed theme, it may not be exactly the same. You can adjust the colors according to your preference.



## vscode

GitHub Copilot: Here are the steps to backup and restore Visual Studio Code settings on different operating systems, including shortcuts, settings.json, installed extensions, and user code snippets:

1. Backup your `settings.json` file. This file is usually located in the `.vscode` directory in the user's home directory. The specific path depends on your operating system:
   - Windows: `%APPDATA%\Code\User\settings.json`
   - macOS: `~/Library/Application Support/Code/User/settings.json`
   - Linux: `~/.config/Code/User/settings.json`

2. Backup your keyboard shortcuts. This file is also in the `.vscode` directory in the user's home directory:
   - Windows: `%APPDATA%\Code\User\keybindings.json`
   - macOS: `~/Library/Application Support/Code/User/keybindings.json`
   - Linux: `~/.config/Code/User/keybindings.json`

3. Backup installed extensions. You can use the `code --list-extensions` command to list all installed extensions, and then save this list to a file.

4. Backup your user code snippets. These files are usually located in the `.vscode` directory in the user's home directory, and the file names end with `.code-snippets`:
   - Windows: `%APPDATA%\Code\User\snippets\*.code-snippets`
   - macOS: `~/Library/Application Support/Code/User/snippets/*.code-snippets`
   - Linux: `~/.config/Code/User/snippets/*.code-snippets`

When restoring, you can follow these steps:

1. Copy the backed-up `settings.json`, `keybindings.json`, and `.code-snippets` files to the corresponding directories on the new system.

2. For installed extensions, you can iterate through the extension list you saved earlier and use the `code --install-extension <extension-id>` command to reinstall these extensions.

Please note that these steps can only backup your settings and extensions, not your workspace settings or specific project settings. If you need to backup these settings, you need to find and backup the corresponding `.vscode` directory.

## vim setting

### clipboard sharing specifications

My environment: remote host os is linux, localhost os is Windows

how can i share clipboard between several instance of environment, including 
1. localhost, 
2. remote host tmux environment 
3. neovim or vim in localhost
3. neovim or vim in remote host. 

which make me can do the following:
1. simply in localhost: copy/paste between neovim/vim instance and system clipboard instance, which means I can press `p` command in vim to paste content from Windows clipboard and paste something into Windows11 application's editor from content in neovim/vim using yank command `y`.
2. simply in remote host: copy/paste between neovim/vim and tmux window, which means I can paste content from vim using `y`(yank) command into tmux windows using `prefix+]` command and paste content from tmux window (first enter visual mode by `prefix+[` command then select text finnally press `enter` command to copy) into vim/neovim using `p` command.
3. cross host sharing: 
    - direction from localhost to remote host: this is basically focusing on paste content from localhost ssystem clipboard, which is Windows, and paste it into neovim/vim using `p` command, since we can easily paste content using `ctrl+v` or `ctrl+shift+v` command to paste content into tmux or shell or other editor in remote host.
    - direction from remote host to localhost: copy content from neovim/vim in remote host or tmux windows and then localhost system clipboard cann share read those content, so i can paste using `ctrl+v` everywhere in Windows.

Now I knew there is one method called "OSC52" which can implement copying from remote host in both tmux and vim to localhost.
