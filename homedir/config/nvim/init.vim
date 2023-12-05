set runtimepath^=~/.vim runtimepath+=~/.vim/after                              
let &packpath = &runtimepath                                                   

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" " predefine config  
" "系统原有配置
let mapleader=";"
"nnoremap <SPACE> <Nop>
"let mapleader=" "
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

autocmd BufWritePost $MYVIMRC source $MYVIMRC

source $HOME/.config/nvim/basic.vim
source $HOME/.config/nvim/plugconfig.vim
source $HOME/.config/nvim/highlight.vim
source $HOME/.config/nvim/cmd.vim
colorscheme github_dark_dimmed
