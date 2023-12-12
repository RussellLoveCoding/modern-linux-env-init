# 路径环境变量
export PATH=$PATH:/usr/local/bin:$HOME/opt/bin
# export PATH=/opt/compiler/gcc-8.2/bin:$PATH

# golang env
export GOROOT=/usr/local/go
export GOPATH=$HOME/go:$HOME/projs 
export PATH=$PATH:$GOROOT/bin:$HOME/go/bin:$HOME/projs/bin
export GOPROXY=direct