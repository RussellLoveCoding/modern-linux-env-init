set runtimepath^=~/.vim runtimepath+=~/.vim/after                              
let &packpath = &runtimepath                                                   

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" " predefine config  
" "系统原有配置
let mapleader=";"
" " let mapleader=" "
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set mouse=a " enable mouse

call plug#begin('~/.vim/plugged')

Plug 'dstein64/nvim-scrollview', { 'branch': 'main' }
highlight ScrollView guifg=#504844

Plug 'terryma/vim-smooth-scroll'
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>

Plug 'joeytwiddle/sexy_scroller.vim'

call plug#end()
