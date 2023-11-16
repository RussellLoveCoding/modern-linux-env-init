""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" non-plugin settings

autocmd BufWritePost ~/.config/nvim/basic.vim source ~/.config/nvim/basic.vim 

set background=dark
colorscheme gruvbox

"""""""""""""""""""""
" key mappings
" map keys to switch between tabs with :tabn and :tabp.
":map <F1> :b1<CR>
":map <F2> :b2<CR>
":map <F3> :b3<CR>
":map <F4> :b4<CR>
":map <F5> :b5<CR>
":map <F6> :b6<CR>
":map <F7> :b7<CR>
":map <F8> :b8<CR>
":map <F8> :b9<CR>
":map <F8> :b10<CR>
":map <F8> :b11<CR>
":map <F8> :b12<CR>
":map <F8> :b13<CR>
":map <F8> :b14<CR>
":map <F8> :b15<CR>
:map <leader>bp :bp<CR>
:map <leader>bn :bn<CR>
:map <leader>bf :Buffers<CR>

"上一个buffer switch betwen last and current buffer.
:map <leader>l <C-^>
":map <F7> :tabn<CR>
":map <F8> :tabp<CR>
"替换 ,s 冲突
":map <leader>

"文件增删改
"以新标签新建文件或打开文件
map <leader>o :tabe<space>

"切分窗口
:map <leader>sp :sp<CR>
:map <leader>vsp :vsp<CR>

" 全选
:map <leader>sa ggvG$

"save as
map <leader><leader>s :save<space>

"save
map <leader>s :wa<CR>

"退出文件
map <leader>q :q!<CR>

"从vim中复制内容到终端外
map <leader>y "+y<CR>

"NERDTree 快捷键
map <leader>nt :NERDTree<CR>

"wa保存所有文件,make编译项目,cw显示编译器抛出的错误和警告信息quickfix
":nmap <Leader>b :wa<CR>:make<CR><CR>:cw<CR>

" fzf find recently used buffers
nmap <silent> <leader>h :History<CR>
"
"remap window split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"search for visually selected text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>  

" navigate to the end of line in Insert Mode
inoremap <C-e> <C-o>$
" navigate to the beginning of line in Insert Mode
inoremap <C-a> <C-o>0
" disable highlighting workds matching pattern
:map <leader>nh :noh<CR>
" 用空格键来开关折叠 
nnoremap <leader><space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR> 

" delete without yanking
" replace currently selected text with default register
" without yanking it
" vnoremap p "_dP
" vnoremap c "_c 
" cnoremap c "_c
" vnoremap C "_C
" cnoremap C "_C    
"""""""""""""""""""""
" crude 'line' text-objects:
" xnoremap il g_o0   
" onoremap il :normal vil<CR>
" xnoremap al $o0
" onoremap al :normal val<CR>

" or implement it like this
" vil selects the printable contents of the line (like ^vg_),
" val selects the entire line contents (like 0v$h).
" xnoremap il ^vg_
" xnoremap al 0v$h 

" crude 'buffer' text-object:
" xnoremap i% GoggV
" onoremap i% :normal vi%<CR>

" using plugin, see plugin kana/vim-textobj-user in plugin config block


" strong default
set backspace=indent,eol,start " 不设定在插入状态无法用退格键和 Delete 键删除回车符

"""""""""""""""""""""
" PLUGIN_ADDING_MARKER
" 其他设定
" 保存.vimrc配置变更立即生效
" 依赖 asyncrun 插件异步更新，也可以去掉 AsyncRun
iabbrev mian main
"set timeoutlen=1000 ttimeoutlen=0 " 消除退出可视模式时的延时
""ics style 
set history=9999		" keep 50 lines of command line history
" 2mat ErrorMsg '\%100v.' " check if #(cols) > 100
noremap % v% " visully select whenever jump
" visually select text whenever type % to jump to matching object
set mouse=a " enable mouse
set autowrite " 在执行':make'时自动保存文件 
setlocal noswapfile " 不要生成swap文件
set bufhidden=hide " 当buffer被丢弃的时候隐藏它
set nocompatible " 关闭 vi 兼容模式
syntax enable " 开启语法高亮功能
syntax on " 允许用指定的语法高亮配色方案替代默认方案
set number " 显示行号
set cursorline " 突出显示当前行
set ruler " 打开状态栏标尺
filetype plugin indent on "自适应不同语言的只能锁紧
set expandtab "将制表符扩展为空格
set shiftwidth=4 " 设定 << 和 >> 命令移动时的宽度为 4
set softtabstop=4 " 使得按退格键时可以一次删掉 4 个空格
set tabstop=4 " 设定 tab 长度为 4
set nobackup " 覆盖文件时不备份
set autochdir " 自动切换当前目录为当前文件所在的目录
set backupcopy=yes " 设置备份时的行为为覆盖
set ignorecase smartcase " 搜索时忽略大小写，但在有一个或以上大写字母时仍保持对大小写敏感
set incsearch " 输入搜索内容时就显示搜索结果
set hlsearch " 搜索时高亮显示被找到的文本
set noerrorbells " 关闭错误信息响铃
set novisualbell " 关闭使用可视响铃代替呼叫
set t_vb= " 置空错误铃声的终端代码
set showmatch " 插入括号时，短暂地跳转到匹配的对应括号
set matchtime=2  "短暂跳转到匹配括号的时间
set magic " 设置魔术
set hidden " 允许在有未保存的修改时切换缓冲区，此时的修改由 vim 负责保存
set smartindent " 开启新行时使用智能自动缩进
set cmdheight=1 " 设定命令行的行数为 1
set laststatus=2 " 显示状态栏 (默认值为 1, 无法显示状态栏)
"set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ Ln\ %l,\ Col\ %c/%L%) " 设置在状态行显示的信息
set foldenable " 开始折叠
set foldmethod=syntax " 设置语法折叠
set foldmethod=indent " 设置缩进折叠
"set cm=blowfish2 加密方法
set foldlevelstart=99 " diablee automatic fold
set nofoldenable    " 启动vim时关闭折叠代码
set foldcolumn=0 " 设置折叠区域的宽度
set previewheight=10
setlocal foldlevel=2 " 设置折叠层数为 1
set autoread
set previewheight=15
" enable hybrid line number, including dynamic number (relative), and absolute number
set number relativenumber 
set nu rnu
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,ucs-bom,chinese
set signcolumn=auto
highlight clear SignColumn
set colorcolumn=80,100
"Open new split panes to right and bottom, which feels more natural than Vim’s default:
set splitbelow 
set splitright
set backup		" keep a backup file 
set conceallevel=3
" set linespace=30

" auto-wrap text, see meaning of each letter by command :h formatoptions and ref
" to fo-table no auto format for paragraph, since vim cannot recognize between
" commented code and commented text, use key stroke command 'gqap' 'gq'
" a paragraph
" par formatter 很强大，但是对于 numbered list 不能够开箱即用，需要认真阅读其
" document 并配置 option
" set formatprg=par1.53
set tw=80 
set formatoptions=croqnmBjp
autocmd FileType markdown set formatoptions+=t
set clipboard=unnamedplus
" 
" Git configuration
"command! -bang -nargs=+ -complete=dir AgIn call s:ag_in(<bang>0, <f-args>)
"g=git
"ga='git add'


""""""""""""""""""""
" non-latin input method auto-switching solution
" autocmd InsertLeave * :silent :!im-select.exe 1033 && im-select.exe 2052

