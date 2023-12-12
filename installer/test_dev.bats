#!/usr/bin/env bats

load 'dev_env.sh'

@test "测试 Github 的安装与卸载" {
    # 设置 distro 变量
    distro="ubuntu"
    # 调用 uninstallGithub 函数
    run uninstallGithub

    # 检查退出状态码，如果 uninstallGithub 函数执行成功，那么状态码应该为 0
    [ "$status" -eq 0 ]

    # 检查输出，确认 gh 是否已被卸载
    run command -v gh
    [ "$status" -ne 0 ]

    # 调用 installGithub 函数
    run installGithub

    # 检查退出状态码，如果 installGithub 函数执行成功，那么状态码应该为 0
    [ "$status" -eq 0 ]

    # 检查输出，确认 gh 是否已被安装
    run command -v gh
    [ "$status" -eq 0 ]
}

@test "测试 bats-core 的安装与卸载" {
    # 调用 installBatscore 函数
    run installBatscore

    # 检查退出状态码，如果 installBatscore 函数执行成功，那么状态码应该为 0
    [ "$status" -eq 0 ]

    # 检查输出，确认 bats 是否已被安装
    run command -v bats
    [ "$status" -eq 0 ]

    # 调用 uninstallBatscore 函数
    run uninstallBatscore

    # 检查退出状态码，如果 uninstallBatscore 函数执行成功，那么状态码应该为 0
    [ "$status" -eq 0 ]

    # 检查输出，确认 bats 是否已被卸载
    run command -v bats
    [ "$status" -ne 0 ]
}