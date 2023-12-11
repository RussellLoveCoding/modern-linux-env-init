#!/usr/bin/env bats

load 'basic_installer.sh'

@test "Test setupShell function" {
    # 运行脚本
    run setupShell

    [ "$status" -eq 0 ]

    run command -v zsh
    [ "$status" -eq 0 ]

    [ -d ~/.oh-my-zsh ]
    [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]
    [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]
    [ -d $ZSH_CUSTOM/plugins/zsh-z ]
    [ -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]
}