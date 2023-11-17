#!/usr/bin/env bats

# Import the source file
# source ./modern_linux_env.sh
load './modern_linux_env.sh'
load './pkgs.sh'

@test "execute_with_timeout should exit with status 1 when command times out" {
    # Call the function with a command that will definitely timeout
    run execute_with_timeout "sleep 2" 1 "Timeout error"
    # Check that the exit status is 1
    [ "$status" -eq 1 ]
    # Check that the output is the error message
    [ "$output" = "Timeout error" ]
}

@test "execute_with_timeout should not exit with status 1 when command does not time out" {
    # Call the function with a command that will not timeout
    run execute_with_timeout "sleep 1" 2 "Timeout error"
    # Check that the exit status is not 1
    [ "$status" -eq 0 ]
}

@test "command_exists should return 0 when command exists" {
    # Call the function with a command that definitely exists
    run command_exists ls
    # Check that the exit status is 0
    [ "$status" -eq 0 ]
}

@test "command_exists should return non-zero when command does not exist" {
    # Call the function with a command that definitely does not exist
    run command_exists nonexistentcommand
    # Check that the exit status is not 0
    [ "$status" -ne 0 ]
}

@test "checkAndAddLine should add line to file if it does not exist" {
    # Create a temporary file
    tmpfile=$(mktemp)
    # Add a line to the file
    line1='export PYENV_ROOT="$HOME/.pyenv"'
    line2='[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
    echo "$line1" >$tmpfile
    # Call the function with a line that does not exist in the file
    checkAndAddLine $tmpfile "$line2"
    # Check that the line was added to the file
    # assertion
    grep -qF "$line1" $tmpfile
    [ "$?" -eq 0 ]
    # assertion
    grep -qF "$line2" $tmpfile
    [ "$?" -eq 0 ]
}

@test "checkAndAddLine should uncomment line if it exists but is commented" {
    # Create a temporary file
    tmpfile=$(mktemp)
    line1='#export PYENV_ROOT="$HOME/.pyenv"'
    line2='# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
    echo "$line1" >>$tmpfile
    echo "$line2" >>$tmpfile
    # Call the function with the line that exists in the file but is commented
    checkAndAddLine $tmpfile "$line1"
    checkAndAddLine $tmpfile "$line2"
    # Check that the line was uncommented
    # assertion
    grep -qF "$line1" $tmpfile
    [ "$?" -eq 0 ]
    # assertion
    grep -qF "$line2" $tmpfile
    [ "$?" -eq 0 ]
}

@test "sshConfig" {
    sshNewPort=12022
    echoContent green " --> this need you to manually test, since cannot read password stdin"
    echoContent green " --> run the following command to test:"
    echoContent green "ssh -p $sshNewPort $user@localhost ls ~"
    echoContent green " --> if it successfully output the home directory, then it is ok"
    # sshConfig $sshNewPort
    # echo "请输入密码：" >&3
    # read -s password
    # user=`ls /home | head -n 1`
    # exp=`sudo ls /home/$user`
    # res=`ssh -p $sshNewPort $user@localhost ls ~`
    # res=`sshpass -p ${password} ssh -p $sshNewPort $user@localhost ls ~`
    # [ "$exp" -eq "$res" ]
}

@test "testInit, including shellprofile, os type, architecture, release detection" {
    init
}

testingEcho() {
    local color=$1
    local content=$2
    case $color in
    "red") echo -e "\033[31m${content}\033[0m" >&3 ;;
    "green") echo -e "\033[32m${content}\033[0m" >&3 ;;
    "yellow") echo -e "\033[33m${content}\033[0m" >&3 ;;
    "blue") echo -e "\033[34m${content}\033[0m" >&3 ;;
    "purple") echo -e "\033[35m${content}\033[0m" >&3 ;;
    "skyblue") echo -e "\033[36m${content}\033[0m" >&3 ;;
    "white") echo -e "\033[37m${content}\033[0m" >&3 ;;
    *) echo "${content}" >&3 ;;
    esac
}

@test "testSetupBasic" {
    isTest=0
    init $isTest
    setupBasicTools
    for pkg in $pkgsKeys; do
        pkgName="$pkg"
        commandName=${pkgsDict[$pkgName]}
        # echoContent green " --> testing $pkgName $commandName"
        if command_exists $commandName; then
            testingEcho green "package $pkgName of command $commandName installed"
        else
            testingEcho red "package $pkgName of command $commandName not installed"
        fi
    done
}
