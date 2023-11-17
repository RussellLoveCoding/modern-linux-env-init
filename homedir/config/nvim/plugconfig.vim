autocmd BufWritePost ~/.config/nvim/plugconfig.vim source ~/.config/nvim/plugconfig.vim 

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-plug
" 如果未安装则自动安装vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" a helper to detect nvim running mode and decide whether to load the plugin 
function! Cond(Cond, ...)
    let opts = get(a:000, 0, {})
    return a:Cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

""""""""""""""""""""
" PLUGIN_BEGIN_MARKER 

""""""""""""""""""""
Plug 'projekt0n/github-nvim-theme'


""""""""""""""""""""
" user-defined text object, defined by a pattern, a pair of patterns, Text
" objects for a specific filetype, see help
Plug 'kana/vim-textobj-user'   
Plug 'kana/vim-textobj-line' 

""""""""""""""""""""
" non-latin input method auto-switching solution
" autocmd InsertLeave * :silent :!im-select.exe 1033 && im-select.exe 2052

""""""""""""""""""""
" vim mode 与中文输入法切换的 seamless 方案，mac-only 快点买mbp
" Plugin 'ybian/smartim'

""""""""""""""""""""
" "自动注释
Plug 'preservim/nerdcommenter'

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not 
let g:NERDToggleCheckAllLines = 1

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Create default mappings
let g:NERDCreateDefaultMappings = 1

" Use compact syntax for prettified multi-line comments
" let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
"let g:NERDDefaultAlign = 'left'

" Set a language to use its alternate delimiters by default
"let g:NERDAltDelims_java = 1

" Add your own custom formats or override the defaults
"let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

" Enable trimming of trailing whitespace when uncommenting
"let g:NERDTrimTrailingWhitespace = 1

" """"""""""""""""""""
" "dash
" "Plug 'rizzatti/dash.vim'
" 

"""""""""""""""""""""
" An always-on highlight for a unique character in every word on a line to help you use f, F and family.
Plug 'unblevable/quick-scope'       
" Trigger a highlight in the appropriate direction when pressing these keys:
" let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

if exists('g:vscode')
    " 
    " """"""""""""""""""""
    " " PLUGIN_BEGIN_MARKER_IN_VSCODE

else
    " " VSCode extension

    """"""""""""""""""""
    " PLUGIN_BEGIN_MARKER_EXPERIMENTAL


    """"""""""""""""""""
    " PLUGIN_BEGIN_MARKER_NOTIN_VSCODE

    """""""""""""""""""
    " java


    """""""""""""""""""
    " session manager
    Plug 'xolox/vim-misc'
    Plug 'xolox/vim-session'

    """""""""""""""""""
    " Plug 'junegunn/vim-easy-align'
    " " Start interactive EasyAlign in visual mode (e.g. vipga)
    " xmap ga <Plug>(EasyAlign)
    " " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    " nmap ga <Plug>(EasyAlign)

    """"""""""""""""""""
    "高效处理 (){}[]<>“” ‘’
    Plug 'tpope/vim-surround' 

    """""""""""""""""""""
    " use normal easymotion when in vim mode
    Plug 'easymotion/vim-easymotion', Cond(!exists('g:vscode'))
    " use vscode easymotion when in vscode mode
    Plug 'asvetliakov/vim-easymotion', Cond(exists('g:vscode'), { 'as': 'vsc-easymotion' })

    "Plug 'easymotion/vim-easymotion'
    let g:EasyMotion_do_mapping = 0 " Disable default mappings

    " Jump to anywhere you want with minimal keystrokes, with just one key binding.
    " `s{char}{label}`
    nmap ' <Plug>(easymotion-overwin-f)
    " or
    " `s{char}{char}{label}`
    " Need one more keystroke, but on average, it may be more comfortable.
    nmap ' <Plug>(easymotion-overwin-f2)


    " Move to line
    map <Leader>L <Plug>(easymotion-bd-jk)
    nmap <Leader>L <Plug>(easymotion-overwin-line)

    " Move to word
    map  <Leader>w <Plug>(easymotion-bd-w)
    nmap <Leader>w <Plug>(easymotion-overwin-w)

    " Turn on case-insensitive feature
    let g:EasyMotion_smartcase = 1

    " JK motions: Line motions
    map <Leader>j <Plug>(easymotion-j)
    map <Leader>k <Plug>(easymotion-k)

    """"""""""""""""""""
    "盘古插件用于自动格式化、标准化中文排版。
    " Plug 'hotoo/pangu.vim'
    " autocmd BufWritePre *.markdown,*.md,*.text,*.txt,*.wiki,*.cnx call PanGuSpacing()

    """"""""""""""""""""
    Plug 'morhetz/gruvbox' , Cond(!exists('g:vscode')) 
    let g:gruvbox_contrast_dark="medium" "中等对比度

    " """""""""""""""""""" 
    " " vimim vim 中文输入法  wozhendhishi 
    " Plug 'ZSaberLv0/ZFVimIM'
    " Plug 'ZSaberLv0/ZFVimJob' "可选, 用于提升词库加载性能 
    " Plug 'ZSaberLv0/ZFVimGitUtil' "可选, 如果你希望定期自动清理词库 push 历史
    " Plug 'HinsonM/ZFVimIM_pinyin_base' "个人词库 
    " Plug 'ZSaberLv0/ZFVimIM_openapi' " 
    " let g:ZFVimIM_pinyin_gitUserEmail='ponhinson@gmail.com'
    " let g:ZFVimIM_pinyin_gitUserName='HinsonM'
    " let g:ZFVimIM_pinyin_gitUserToken='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'

    """"""""""""""""""""
    "自动读取当前buffer文件的新内容
    " Plug 'djoshea/vim-autoread' 

    """"""""""""""""""""
    Plug 'jiangmiao/auto-pairs'

    """"""""""""""""""""
    " 异步执行命令
    " Plug 'skywind3000/asyncrun.vim' 

    """""""""""""""""
    " ranger as a popup window in vim
    " Plug 'kevinhwang91/rnvimr'

    """""""""""""""""
    "scrollbar
    Plug 'dstein64/nvim-scrollview', { 'branch': 'main' }
    " highlight ScrollView guifg=#504844
    " highlight ScrollView guifg=red
    " Link ScrollView highlight to Pmenu highlight
    " highlight link ScrollView Comment
    " highlight link ScrollView Pmenu 
    " Specify custom highlighting for ScrollView
    highlight ScrollView guibg=#7a6e63
    let g:scrollview_excluded_filetypes = ['nerdtree']

    """""""""""""""""
    " Plug 'Xuyuanp/scrollbar.nvim'
    " augroup your_config_scrollbar_nvim
        " autocmd!
        " autocmd WinScrolled,VimResized,QuitPre * silent! lua require('scrollbar').show()
        " autocmd WinEnter,FocusGained           * silent! lua require('scrollbar').show()
        " autocmd WinLeave,BufLeave,BufWinLeave,FocusLost            * silent! lua require('scrollbar').clear()
    " augroup end
" 
" 
    " highlight ScrollBar guifg=#504844
    " let g:scrollbar_highlight = {
                " \ 'head': 'ScrollBar',
                " \ 'body': 'ScrollBar',
                " \ 'tail': 'ScrollBar',
                " \ }
    " let g:scrollbar_width = 1

    """""""""""""""""
    " 高亮 colorcode
    " Plug 'norcalli/nvim-colorizer.lua'
    " lua require'colorizer'.setup()

    """"""""""""""""""""
    " A Vim / Neovim plugin to copy text to the system clipboard from anywhere using the ANSI OSC52 sequence.
    Plug 'ojroques/vim-oscyank', {'branch': 'main'}
    " Content will be copied to clipboard after any yank operation
    autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif
    " By default you can copy up to 100000 characters at once. If your terminal supports it, you can raise that limit with:
    let g:oscyank_max_length = 1000000
    " specify tmux  for the terminal emulator to avoid automatic detection 
    " let g:oscyank_term = 'tmux'  " or 'screen', 'kitty', 'default'
    " By default a confirmation message is echoed after text is copied. This can be disabled with:
    let g:oscyank_silent = v:true  " or 1 for older versions of Vim


    """"""""""""""""""""
    " Plug 'crusoexia/vim-monokai'

    """"""""""""""""""""""
    " " navigate between vim and tmux
    Plug 'christoomey/vim-tmux-navigator'

    " """"""""""""""""""""
    " " 无法使用
    " " Plug 'vim-scripts/VimIM'
    " " let g:vimim_cloud = 'google,sogou,baidu,qq'  
    " " let g:vimim_map = 'tab_as_gi'  
    " " let g:vimim_mode = 'dynamic'  
    " " let g:vimim_mycloud = 0  
    " " " let g:vimim_plugin = 'C:/var/mobile/vim/vimfiles/plugin'  
    " " let g:vimim_punctuation = 2  
    " " let g:vimim_shuangpin = 0  
    " " let g:vimim_toggle = 'pinyin,google,sogou' 

    " """"""""""""""""""""
    " " markdown render
    " Plug 'ellisonleao/glow.nvim'
    " 
    " """""""""""""""""""""
    " " Plug 'scrooloose/syntastic', Cond(!exists('g:vscode'))
    " 
    " "set statusline+=%#warningmsg#
    " "set statusline+=%{SyntasticStatuslineFlag()}
    " "set statusline+=%*
    " 
    " "let g:syntastic_always_populate_loc_list = 1
    " "let g:syntastic_auto_loc_list = 1
    " "let g:syntastic_check_on_open = 1
    " "let g:syntastic_check_on_wq = 0


    " """""""""""""""""""""
    " Plug 'nvim-lualine/lualine.nvim'
    " " If you want to have icons in your statusline choose one of these
    " let g:lightline = {
      " \ 'tabline': {
      " \   'right': [['CurrentFunction']]
      " \ },
      " \ 'component_function': {
      " \   'CurrentFunction': 'CocCurrentFunction'
      " \ },
      " \ 'component_type': {'buffers': 'tabsel'},
      " \ 'separator':      {'left': "\ue0b0", 'right': "\ue0b2"},
      " \ 'subseparator':   {'left': "\ue0b1", 'right': "\ue0b3"}
      " \ }

    " """""""""""""""""""""
    " 整合vim和tmux的状态栏
    " Plug 'edkolev/tmuxline.vim'
    " let g:tmuxline_preset = 'tmux'
    " other presets available in autoload/tmuxline/presets/*
    
    " status 显示内容
    " let g:tmuxline_preset = {
    " \'a'    : '#S',
    " \'b'    : ['#(whoami) @ #h'],
    " \'win'  : ['#I', '#W'],
    " \'cwin' : ['#I', '#W', '#F'],
    " \'z'    : '#(date +"%F %T")'}
    
    " let g:tmuxline_theme = {
    " \   'a'    : [ 236, 103 ],
    " \   'b'    : [ 253, 239 ],
    " \   'c'    : [ 244, 236 ],
    " \   'x'    : [ 244, 236 ],
    " \   'y'    : [ 253, 239 ],
    " \   'z'    : [ 236, 103 ],
    " \   'win'  : [ 103, 236 ],
    " \   'cwin' : [ 255, 0 ],
    " \   'bg'   : [ 244, 236 ],
    " \ }
    
    
    " """""""""""""""""""""
    let g:LanguageClient_serverCommands = {
                \ 'sql': ['sql-language-server', 'up', '--method', 'stdio'],
                \ }


    " """""""""""""""""""""
    " " vim 和 tmux 共享剪贴板
    " " 该插件会导致复制一行后再粘贴时，丢失换行符，之际在光标位置粘贴行内容
    " " 但是又能够tmux 和 vim 剪贴板共享,估计应该是另外一个插件起作用.
    " Plug 'tmux-plugins/vim-tmux-focus-events', Cond(!exists('g:vscode'))
    " Plug 'roxma/vim-tmux-clipboard', Cond(!exists('g:vscode'))

    """"""""""""""""""""
    " inline blame inspired by vscode gitlens
    Plug 'APZelos/blamer.nvim'
    let g:blamer_delay = 500
    let g:blamer_enabled = 1
    let g:blamer_show_in_visual_modes = 1
    let g:blamer_show_in_insert_modes = 1
    let g:blamer_date_format = '%y-%m-%d %H:%M'


    """"""""""""""""""""
    Plug 'tpope/vim-fugitive', Cond(!exists('g:vscode'))
    nnoremap <Leader>gdh :Ghdiffsplit<CR>
    nnoremap <Leader>gdv :Gvdiffsplit<CR>

    """""""""""""""""""""
    " 可以在文档中显示 git 信息
    Plug 'airblade/vim-gitgutter' , Cond(!exists('g:vscode')) 
    " "highlight SignColumn guibg= ctermbg=whatever
    let g:gitgutter_set_sign_backgrounds = 1
    let g:gitgutter_preview_win_floating = 1
    " highlight GitGutterAdd    guifg=#009900 ctermfg=0
    " highlight GitGutterChange guifg=#bbbb00 ctermfg=0
    " highlight GitGutterDelete guifg=#ff2222 ctermfg=0
    hi GitGutterAdd        ctermfg=142 ctermbg=235 guifg=ctermfg guibg=#3e563e
    hi GitGutterChange     ctermfg=108 ctermbg=235 guifg=ctermfg guibg=#2c3435
    hi GitGutterDelete     ctermfg=167 ctermbg=235 guifg=#3a3030 guibg=#3a3030
    "hi DiffText       ctermfg=214 ctermbg=235 guifg=ctermfg guibg=#254a50
    "highlight GitGutterDelete guifg=#c93c3733 ctermfg=0  #46954a33  #2a3c33 #442d30

    ""DELETED_LINE_NO_COLOR": {
    "    "color": "#e5534b",
    " no buffers
    "    "backgroundColor": "#c93c371a"
    "},
    ""INSERTED_LINE_NO_COLOR": {
    ""color": "#57ab5a",
    ""backgroundColor": "#46954a1a"
    "},

    """"""""""""""""""""
    " " Track the engine.
    " " Snippets are separated from the engine. Add this if you want them:
    " Plug 'honza/vim-snippets', Cond(!exists('g:vscode'))

    """"""""""""""""""""
    " " sql 交互
    " Plug 'tpope/vim-dadbod', Cond(!exists('g:vscode')) 

    """"""""""""""""""""
    " " 彩虹括号
    Plug 'luochen1990/rainbow', Cond(!exists('g:vscode')) 
    let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle
    let g:rainbow_conf = {
                \	'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
                \	'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
                \	'operators': '_,_',
                \	'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
                \	'separately': {
                \		'*': {},
                \		'tex': {
                \			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
                \		},
                \		'lisp': {
                \			'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
                \		},
                \		'vim': {
                \			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
                \		},
                \		'html': {
                \			'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
                \		},
                \		'css': 0,
                \		'nerdtree': 0,
                \	}
                \}

    """"""""""""""""""""
    " consider plugin kyazdani42/nvim-tree.lua "增加indentline 
    " 树状文件浏览器
    " Plug 'preservim/nerdtree', Cond(!exists('g:vscode')) 
    " " 可以使 nerdtree 的 tab 更加友好些
    " Plug 'jistr/vim-nerdtree-tabs', Cond(!exists('g:vscode')) 
    " " 可以在导航目录中看到 git 版本信息
    " Plug 'Xuyuanp/nerdtree-git-plugin', Cond(!exists('g:vscode')) 

    " " nerdtree设置
    " augroup nerdtreeconcealbrackets
        " autocmd!
        " autocmd FileType nerdtree syntax match hideBracketsInNerdTree "\]" contained conceal containedin=ALL cchar= 
        " autocmd FileType nerdtree syntax match hideBracketsInNerdTree "\[" contained conceal containedin=ALL
        " autocmd FileType nerdtree setlocal conceallevel=2
        " autocmd FileType nerdtree setlocal concealcursor=nvic
    " augroup END
" 
    " " "  nerdtree-git-plugin 插件
    " let g:NERDTreeGitStatusIndicatorMapCustom = {
                " \ "Modified"  : "✹",
                " \ "Staged"    : "✚",
                " \ "Untracked" : "✭",
                " \ "Renamed"   : "➜",
                " \ "Unmerged"  : "═",
                " \ "Deleted"   : "✖",
                " \ "Dirty"     : "✗",
                " \ "Clean"     : "✔︎",
                " \ 'Ignored'   : '☒',
                " \ "Unknown"   : "?"
                " \ }
" 
    " let g:NERDTreeGitStatusShowIgnored = 1
    " " "[nerdtree-git-status] option 'g:NERDTreeShowIgnoredStatus' is deprecated, please use 'g:NERDTreeGitStatusShowIgnored'
    " " "[nerdtree-git-status] option 'g:NERDTreeIndicatorMapCustom' is deprecated, please use 'g:NERDTreeGitStatusIndicatorMapCustom'
" 
    """"""""""""""""""""
    " " welcome page ag
    Plug 'mhinz/vim-startify' , Cond(!exists('g:vscode')) 

    """"""""""""""""""""
    " "连接某一个scope的竖线
    Plug 'Yggdroot/indentLine' , Cond(!exists('g:vscode')) 
    let g:indentLine_char_list = ['|'] "['|', '¦', '┆', '┊']
    let g:vim_json_conceal = 0
    " "let g:vim_json_conceal = -1
    let g:vim_markdown_conceal_code_blocks = 0
    let g:vim_markdown_conceal = 0
    autocmd FileType go setlocal expandtab
    autocmd FileType go set list lcs=tab:\|\ "(last character is a space...)

    """"""""""""""""""""
    " "sublime 的多光标功能
    Plug 'terryma/vim-multiple-cursors' , Cond(!exists('g:vscode')) 

    """"""""""""""""""""
    " Plug 'tpope/vim-eunuch', Cond(!exists('g:vscode')) 

    """"""""""""""""""""
    " Plug 'mattn/emmet-vim', Cond(!exists('g:vscode')) 

    """"""""""""""""""""
    " " Plug 'sainnhe/gruvbox-material', Cond(!exists('g:vscode')) 

    """"""""""""""""""
    "Plug 'prabirshrestha/vim-lsp', Cond(!exists('g:vscode')) 
    "Plug 'mattn/vim-lsp-settings', Cond(!exists('g:vscode')) 
    "
    "

    """""""""""""""""""""
    " Plug 'vim-scripts/SQLUtilities' 

    """""""""""""""""""""
    " Plug 'rking/ag.vim' , Cond(!exists('g:vscode')) 
    " "ag search
    " "https://blog.csdn.net/ballack_linux/article/details/53187283
    " 
    " " for easy using sliver search
    " nmap <leader>f :norm yiw<CR>:Ag! -t -Q "<C-R>""
    " nmap <leader>r :norm yiw<CR>:Ag! -t "\b<C-R>"\b"
    " 
    " "" Locate and return character "above" current cursor position.
    " function! LookUpwards()
    " let column_num = virtcol('.')
    " let target_pattern = '\%' . column_num . 'v.'
    " let target_line_num = search(target_pattern . '*\S', 'bnW')
    " 
    " 
    " if !target_line_num
    " return ""
    " else
    " return matchstr(getline(target_line_num), target_pattern)
    " endif
    " endfunction
    " 
    " imap <silent> <C-Y> <C-R><C-R>=LookUpwards()<CR>


    """""""""""""""""""""
    " 启动该插件后，会使得 normal 模式下的一些键位功能异常,如 通过 dd 来删除
    " 一行内容后,再通过 p 来粘贴，粘贴内容的前导 \n  字符没有了，就是直接所粘贴
    " 内容紧跟着光别所在处。
    " Plug 'plasticboy/vim-markdown', Cond(!exists('g:vscode')) 
    " " " markdown-preview
    " Plug 'iamcco/mathjax-support-for-mkdp', Cond(!exists('g:vscode')) 
    " Plug 'iamcco/markdown-preview.nvim', Cond(!exists('g:vscode'),{ 'do': 'cd app && yarn install' })
    " " set to 1, nvim will open the preview window after entering the markdown buffer
    " " default: 0
    " let g:mkdp_auto_start = 0
" 
    " " set to 1, the nvim will auto close current preview window when change
    " " from markdown buffer to another buffer
    " " default: 1
    " let g:mkdp_auto_close = 1
" 
    " " set to 1, the vim will refresh markdown when save the buffer or
    " " leave from insert mode, default 0 is auto refresh markdown as you edit or
    " " move the cursor
    " " default: 0
    " let g:mkdp_refresh_slow = 0
" 
    " " set to 1, the MarkdownPreview command can be use for all files,
    " " by default it can be use in markdown file
    " " default: 0
    " let g:mkdp_command_for_global = 0
" 
    " " set to 1, preview server available to others in your network
    " " by default, the server listens on localhost (127.0.0.1)
    " " default: 0
    " let g:mkdp_open_to_the_world = 1
" 
    " " use custom IP to open preview page
    " " useful when you work in remote vim and preview on local browser
    " " more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9
    " " default empty
    " let g:mkdp_open_ip = '192.168.0.105' 
" 
    " " specify browser to open preview page
    " " default: ''
    " let g:mkdp_browser = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
" 
    " " set to 1, echo preview page url in command line when open preview page
    " " default is 0
    " let g:mkdp_echo_preview_url = 1
" 
    " " a custom vim function name to open preview page
    " " this function will receive url as param
    " " default is empty
    " function! g:EchoUrl(url)
        " :echo a:url
    " endfunction
    " let g:mkdp_browserfunc = ''
" 
    " " options for markdown render
    " " mkit: markdown-it options for render
    " " katex: katex options for math
    " " uml: markdown-it-plantuml options
    " " maid: mermaid options
    " " disable_sync_scroll: if disable sync scroll, default 0
    " " sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
    " "   middle: mean the cursor position alway show at the middle of the preview page
    " "   top: mean the vim top viewport alway show at the top of the preview page
    " "   relative: mean the cursor position alway show at the relative positon of the preview page
    " " hide_yaml_meta: if hide yaml metadata, default is 1
    " " sequence_diagrams: js-sequence-diagrams options
    " " content_editable: if enable content editable for preview page, default: v:false
    " " disable_filename: if disable filename header for preview page, default: 0
    " let g:mkdp_preview_options = {
                " \ 'mkit': {},
                " \ 'katex': {},
                " \ 'uml': {},
                " \ 'maid': {},
                " \ 'disable_sync_scroll': 0,
                " \ 'sync_scroll_type': 'middle',
                " \ 'hide_yaml_meta': 1,
                " \ 'sequence_diagrams': {},
                " \ 'flowchart_diagrams': {},
                " \ 'content_editable': v:false,
                " \ 'disable_filename': 0
                " \ }
" 
    "  use a custom markdown style must be absolute path
    " like '/Users/username/markdown.css' or expand('~/markdown.css')
    " let g:mkdp_markdown_css = ''
" 
    " use a custom highlight style must absolute path
    " like '/Users/username/highlight.css' or expand('~/highlight.css')
    " let g:mkdp_highlight_css = ''
" 
    " " " use a custom port to start server or random for empty
    " let g:mkdp_port = 8001
" 
    " " " preview page title
    " " " ${name} will be replace with the file name
    " let g:mkdp_page_title = '「${name}」'
" 
    " " " recognized filetypes
    " " " these filetypes will have MarkdownPreview... commands
    " let g:mkdp_filetypes = ['markdown']

    " """""""""""""""""""""
    " Plug '907th/vim-auto-save', Cond(!exists('g:vscode')) 
    " let g:auto_save = 1  " enable AutoSave on Vim startup
    " let g:auto_save_silent = 1  " do not display the auto-save notification
    " let g:auto_save_events = ["InsertLeave", "TextChanged"]
    " let g:auto_save_write_all_buffers = 1  " write all open buffers as if you would use :wa
    " 
    " """""""""""""""""""
    " " Plug 'SirVer/ultisnips', Cond(!exists('g:vscode')) 
    " " Trigger configuration. You need to change this to something other than <tab> if you use one of the following:
    " " - https://github.com/Valloric/YouCompleteMe
    " " - https://github.com/nvim-lua/completion-nvim
    " " let g:UltiSnipsExpandTrigger="<tab>"
    " " let g:UltiSnipsJumpForwardTrigger="<c-b>"
    " " let g:UltiSnipsJumpBackwardTrigger="<c-z>"
    " " 
    " " " If you want :UltiSnipsEdit to split your window.
    " " let g:UltiSnipsEditSplit="vertical"
    " 
    " 
    " "command! -bang -nargs=+  call s:ag_in(<bang>0, <f-args>)

    """""""""""""""""""""
    "
    " Plug 'karb94/neoscroll.nvim'
    " lua require('neoscroll').setup()
    " require('neoscroll').setup()

    """""""""""""""""""""
    "vscode specific
    Plug 'airblade/vim-rooter' , Cond(!exists('g:vscode')) 
    let g:rooter_patterns = ['.git', 'Makefile', '*.sln', 'build/env.sh']

    " """""""""""""""""""""
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } 
    Plug 'junegunn/fzf.vim' , Cond(!exists('g:vscode')) 

    " 全局搜索
    " ps: project search; pf: project files; pt: project tag; pg; project tags
    map <leader>rg :Rg<space>
    map <leader>ps :Ag<CR>
    map <leader>pf :Files<CR>
    nnoremap <leader>pt :BTags<CR>
    nnoremap <leader>pg :Tags<CR>

    " [Buffers] Jump to the existing window if possible
    let g:fzf_buffers_jump = 1

    " [[B]Commits] Customize the options used by 'git log':
    let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

    " [Tags] Command to generate tags file
    let g:fzf_tags_command = 'ctags -R'

    " [Commands] --expect expression for directly executing the command
    let g:fzf_commands_expect = 'alt-enter,ctrl-x'

    command! -bang -nargs=* Rag call fzf#vim#ag(<q-args>,  <bang>0)

    command! FZFMru call fzf#run({
                \  'source':  v:oldfiles,
                \  'sink':    'e',
                \  'options': '-m -x +s',
                \  'down':    '40%'})

    nnoremap <leader>mru :FZFMru<CR>
    " nnoremap <leader> :FZFMru<CR>
    nnoremap <leader>C :Commands<CR>


    " ProjectFiles tries to locate files relative to the git root contained in
    " NerdTree, falling back to the current NerdTree dir if not available
    " see https://github.com/junegunn/fzf.vim/issues/47#issuecomment-160237795
    " 有时行，有时不行
    " function! s:find_files()
    " let git_dir = system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
    " if git_dir != ''
    " execute 'GFiles' git_dir
    " else
    " execute 'Files'
    " endif
    " endfunction
    " command! ProjectFiles execute s:find_files()
    " nnoremap <leader>p :ProjectFiles<CR>
    " 
    " " search in the root dir
    " "function! s:with_git_root()
    " "let root = systemlist('git rev-parse --show-toplevel')[0]
    " "return v:shell_error ? {} : {'dir': root}
    " "endfunction

    " "command! -nargs=* Rag
    " "\ call fzf#vim#ag(<q-args>, extend(s:with_git_root(), g:fzf#vim#default_layout))

    " "let groot = systemlist('git -C ' . expanld('%:p:h') . ' rev-parse --show-toplevel')[0]
    " "command! -nargs=* Rag
    " "\ call fzf#vim#ag(<q-args>, extend(g:rc#git#groot(), g:fzf_layout))

    " "command! Rag 
    " "\ call fzf#vim#ag(a:query, extend({
    " "\'dir': g:rc#git#groot(),
    " "\g:fzf_layout))


    " " AgIn: Start ag in the specified directory
    " "
    " " e.g.
    " "   :AgIn .. foo
    " function! s:ag_in(bang, ...)
    " if !isdirectory(a:1)
    " throw 'not a valid directory: ' .. a:1
    " endif
    " " " Press `?' to enable preview window.
    " call fzf#vim#ag(join(a:000[1:], ' '), fzf#vim#with_preview({'dir': a:1}, 'up:50%:hidden', '?'), a:bang)
    " 
    " " " If you don't want preview option, use this
    " " " call fzf#vim#ag(join(a:000[1:], ' '), {'dir': a:1}, a:bang)
    " endfunction
    " 
    " command! -bang -nargs=+ -complete=dir AgIn call s:ag_in(<bang>0, <f-args>)

    " function! s:find_it_root()
    " return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
    " endfunction
    " 
    " command! ProjectFiles execute 'Files' s:find_git_root()
    " 
    " """""""""""""""""""""
    " "自动索引
    Plug 'ludovicchabant/vim-gutentags' 
    " " gutentags 搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归
    let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']

    " " 所生成的数据文件的名称
    let g:gutentags_ctags_tagfile = '.tags'

    " " 将自动生成的 tags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
    let s:vim_tags = expand('~/.cache/tags')
    let g:gutentags_cache_dir = s:vim_tags

    " " 配置 ctags 的参数
    let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
    let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
    let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

    " " 检测 ~/.cache/tags 不存在就新建
    if !isdirectory(s:vim_tags)
        silent! call mkdir(s:vim_tags, 'p')
    endif

    " """""""""""""""""""""
    " "基于标签将标识符分类显示于左侧
    Plug 'majutsushi/tagbar'
    let g:tagbar_autoclose = 0
    " "基于标签将标识符分类显示于左侧
    " " 设置 tagbar 子窗口的位置出现在主编辑区的左边
    " "let tagbar_left=1
    let tagbar_right=1
    " " 设置显示／隐藏标签列表子窗口的快捷键。速记：identifier list by tag
    " "nmap <F8> :TagbarToggle<CR>
    nnoremap <Leader>il :TagbarToggle<CR>
    " " 设置标签子窗口的宽度
    let tagbar_width=22
    let g:NERDTreeWinSize=22
    " " tagbar 子窗口中不显示冗余帮助信息
    let g:tagbar_compact=1
    " " 设置 ctags 对哪些代码标识符生成标签
    let g:tagbar_type_cpp = {
                \ 'kinds' : [
                    \ 'c:classes:0:1',
                    \ 'd:macros:0:1',
                    \ 'e:enumerators:0:0',
                    \ 'f:functions:0:1',
                    \ 'g:enumeration:0:1',
                    \ 'l:local:0:1',
                    \ 'm:members:0:1',
                    \ 'n:namespaces:0:1',
                    \ 'p:functions_prototypes:0:1',
                    \ 's:structs:0:1',
                    \ 't:typedefs:0:1',
                    \ 'u:unions:0:1',
                    \ 'v:global:0:1',
                    \ 'x:external:0:1'
                    \ ],
                    \ 'sro'        : '::',
                    \ 'kind2scope' : {
                        \ 'g' : 'enum',
                        \ 'n' : 'namespace',
                        \ 'c' : 'class',
                        \ 's' : 'struct',
                        \ 'u' : 'union'
                        \ },
                        \ 'scope2kind' : {
                            \ 'enum'      : 'g',
                            \ 'namespace' : 'n',
                            \ 'class'     : 'c',
                            \ 'struct'    : 's',
                            \ 'union'     : 'u'
                            \ }
                            \ }

    " " """""""""""""""""""""
    " vim-go
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
    " " vim-go quickfix list 之间的跳转
    map <C-n> :cnext<CR>
    map <C-m> :cprevious<CR>
    nnoremap <leader>cq :cclose<CR>
    
    nnoremap <leader>de :GoDecls<CR>
    nnoremap <leader>ds :GoDeclsDir<CR>
    
    autocmd FileType go nmap <leader>r  <Plug>(go-run)
    autocmd FileType go nmap <leader>t  <Plug>(go-test)
    
    " " run :GoBuild or :GoTestCompile based on the go file
    function! s:build_go_files()
    let l:file = expand('%')
    if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
    elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
    endif
    endfunction
    
    autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
    
    " automatically import or remove a package each time you save a file
    let g:go_fmt_command = "goimports"

    """"""""""""""""""""
    " Plug 'ryanoasis/vim-devicons', Cond(!exists('g:vscode'))

    """"""""""""""""""""
    Plug 'kyazdani42/nvim-web-devicons'

    " """""""""""""""""""""
    " " coc.vim 补全框架
    Plug 'neoclide/coc.nvim', Cond(!exists('g:vscode') , {'branch': 'release'})

    " coc extensions
    " coc-sql SQL extension for coc.nvim. Features: Format by sql-formatter; Lint by node-sql-parser
    let g:coc_global_extensions = ['coc-json', 'coc-tsserver', 'coc-ci', 
                \ 'coc-sql', 'coc-sh', 'coc-java', 'coc-explorer', 
                \  'coc-metals']
    "'coc-git', 'coc-snippets', 'coc-java-debug', 'coc-git',  'coc-pyright', 'coc-go'
    " Set internal encoding of vim, not needed on neovim, since coc.nvim using some
    " unicode characters in the file autoload/float.vim

    " TextEdit might fail if hidden is not set.
    set hidden

    " Some servers have issues with backup files, see #649.
    set nobackup
    set nowritebackup

    " Give more space for displaying messages.
    " set cmdheight=2

    " " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
    " " delays and poor user experience.
    set updatetime=300

    "" Don't pass messages to |ins-completion-menu|.
    set shortmess+=c

    " " Always show the signcolumn, otherwise it would shift the text each time
    " " diagnostics appear/become resolved.
    " "if has("nvim-0.5.0") || has("patch-8.1.1564")
    ""Recently vim can merge signcolumn and number column into one
    " "set signcolumn=number
    " "else
    " "set signcolumn=yes
    " "endif

    set signcolumn=auto
    highlight clear SignColumn
    " " if signcolumn=yes, then line number would be covered by symbol
    " " Use tab for trigger completion with characters ahead and navigate.
    " " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
    " " other plugin before putting this into your config.
    inoremap <silent><expr> <TAB>
                \ pumvisible() ? "\<C-n>" :
                \ <SID>check_back_space() ? "\<TAB>" :
                \ coc#refresh()
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    " " Use <c-space> to trigger completion.
    if has('nvim')
        inoremap <silent><expr> <c-space> coc#refresh()
    else
        inoremap <silent><expr> <c-@> coc#refresh()
    endif

    " " Make <CR> auto-select the first completion item and notify coc.nvim to
    " " format on enter, <cr> could be remapped by other vim plugin
    inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

    " " Use `[g` and `]g` to navigate diagnostics
    " " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)

    " " GoTo code navigation.
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    " " Use K to show documentation in preview window.
    nnoremap <silent> K :call <SID>show_documentation()<CR>

    function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
        elseif (coc#rpc#ready())
            call CocActionAsync('doHover')
        else
            execute '!' . &keywordprg . " " . expand('<cword>')
        endif
    endfunction

    " " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " " Symbol renaming.
    nmap <leader>rn <Plug>(coc-rename)
    nmap <leader>rf <plug>(coc-refactor)

    " " Formatting selected code.
    xmap <leader>f  <Plug>(coc-format-selected)
    nmap <leader>f  <Plug>(coc-format-selected)

    augroup mygroup
        autocmd!
        "" Setup formatexpr specified filetype(s).
        autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
        "" Update signature help on jump placeholder.
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    augroup end

    " " Applying codeAction to the selected region.
    " " Example: `<leader>aap` for current paragraph
    xmap <leader>a  <Plug>(coc-codeaction-selected)
    nmap <leader>a  <Plug>(coc-codeaction-selected)

    " " Remap keys for applying codeAction to the current buffer.
    nmap <leader>ac  <Plug>(coc-codeaction)
    " " Apply AutoFix to problem on the current line.
    nmap <feader>qf  <Plug>(coc-fix-current)

    " " Map function and class text objects
    " " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
    xmap if <Plug>(coc-funcobj-i)
    omap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap af <Plug>(coc-funcobj-a)
    xmap ic <Plug>(coc-classobj-i)
    omap ic <Plug>(coc-classobj-i)
    xmap ac <Plug>(coc-classobj-a)
    omap ac <Plug>(coc-classobj-a)

    " " Remap <C-f> and <C-b> for scroll float windows/popups.
    if has('nvim-0.4.0') || has('patch-8.2.0750')
        nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
        nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
        inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
        inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
        vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
        vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    endif

    " " Use CTRL-S for selections ranges.
    " " Requires 'textDocument/selectionRange' support of language server.
    nmap <silent> <C-s> <Plug>(coc-range-select)
    xmap <silent> <C-s> <Plug>(coc-range-select)

    " " Add `:Format` command to format current buffer.
    command! -nargs=0 Format :call CocAction('format')

    " " Add `:Fold` command to fold current buffer.
    command! -nargs=? Fold :call     CocAction('fold', <f-args>)

    " " Add `:OR` command for organize imports of the current buffer.
    command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

    " Add (Neo)Vim's native statusline support.
    " NOTE: Please see `:h coc-status` for integrations with external plugins that
    " provide custom statusline: lightline.vim, vim-airline.
    set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

    " " Mappings for CoCList
    " " Show all diagnostics.
    nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
    " " Manage extensions.
    nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
    " " Show commands.
    nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
    " " Find symbol of current document.
    nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
    " " Search workspace symbols.
    nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
    " " Do default action for next item.
    nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
    " " Do default action for previous item.
    nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
    " " Resume latest coc list.
    nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>


    """"""""""""""""""""
    " " coc-ci 支持中文分词
    nmap <silent> w <plug>(coc-ci-w)
    nmap <silent> b <plug>(coc-ci-b)

    """""""""""""""""""""
    " another fuzzy finder, find everything, including git ...
    " Plug 'nvim-lua/plenary.nvim'
    " Plug 'nvim-telescope/telescope.nvim'


    """""""""""""""""""""
    " On-demand lazy load
    " Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
    " Plug 'liuchengxu/vim-which-key'
    " To register the descriptions when using the on-demand load feature,
    " use the autocmd hook to call which_key#register(), e.g., register for the Space key:
    " autocmd! User vim-which-key call which_key#register('<Space>', 'g:which_key_map')

    """"""""""""""""""""
    " coc-explorer
    let g:coc_explorer_global_presets = {
                \   '.vim': {
                    \     'root-uri': '~/.vim',
                    \   },
                    \   'cocConfig': {
                        \      'root-uri': '~/.config/coc',
                        \   },
                        \   'tab': {
                            \     'position': 'tab',
                            \     'quit-on-open': v:true,
                            \   },
                            \   'tab:$': {
                                \     'position': 'tab:$',
                                \     'quit-on-open': v:true,
                                \   },
                                \   'floating': {
                                    \     'open-action-strategy': 'sourceWindow',
                                    \     'position': 'floating',
                                    \   },
                                    \   'floatingTop': {
                                        \     'position': 'floating',
                                        \     'floating-position': 'center-top',
                                        \     'open-action-strategy': 'sourceWindow',
                                        \   },
                                        \   'floatingLeftside': {
                                            \     'position': 'floating',
                                            \     'floating-position': 'left-center',
                                            \     'floating-width': 50,
                                            \     'open-action-strategy': 'sourceWindow',
                                            \   },
                                            \   'floatingRightside': {
                                                \     'position': 'floating',
                                                \     'floating-position': 'right-center',
                                                \     'floating-width': 50,
                                                \     'open-action-strategy': 'sourceWindow',
                                                \   },
                                                \   'simplify': {
                                                    \     'file-child-template': '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'
                                                    \   },
                                                    \   'buffer': {
                                                        \     'sources': [{'name': 'buffer', 'expand': v:true}],
                                                        \     'position': 'floating',
                                                        \   },
                                                        \ }

    " Use preset argument to open it
    nmap <space>e <Cmd>CocCommand explorer<CR>
    nmap <space>ed <Cmd>CocCommand explorer --preset .vim<CR>
    nmap <space>ef <Cmd>CocCommand explorer --preset floating<CR>
    nmap <space>ec <Cmd>CocCommand explorer --preset cocConfig<CR>
    nmap <space>eb <Cmd>CocCommand explorer --preset buffer<CR>

    " List all presets
    nmap <space>el <Cmd>CocList explPresets<CR>

    """"""""""""""""""""
    " coc-go
    " autocmd BufWritePre *.go :silent call CocAction('runCommand', 'editor.action.organizeImport')
    " autocmd FileType go nmap gtj :CocCommand go.tags.add json<cr>
    " autocmd FileType go nmap gty :CocCommand go.tags.add yaml<cr>
    " autocmd FileType go nmap gtx :CocCommand go.tags.clear<cr>


    Plug 'liuchengxu/vista.vim'
    function! NearestMethodOrFunction() abort
        return get(b:, 'vista_nearest_method_or_function', '')
    endfunction

    set statusline+=%{NearestMethodOrFunction()}

    " By default vista.vim never run if you don't call it explicitly.
    "
    " If you want to show the nearest function in your statusline automatically,
    " you can add the following line to your vimrc
    autocmd VimEnter * call vista#RunForNearestMethodOrFunction()

    Plug 'itchyny/lightline.vim'
    " let g:lightline = {
    " \ 'colorscheme': 'wombat',
    " \ 'active': {
    " \   'left': [ [ 'mode', 'paste' ],
    " \             [ 'readonly', 'filename', 'modified', 'method' ] ]
    " \ },
    " \ 'component_function': {
    " \   'method': 'NearestMethodOrFunction'
    " \ },
    " \ }
    let g:lightline = {
                \ 'colorscheme': 'wombat',
                \ 'active': {
                    \   'left': [ [ 'mode', 'paste' ],
                    \             [ 'gitbranch', 'readonly', 'filename', 'modified'] , ['method'] ]
                    \ },
                    \ 'component_function': {
                        \   'gitbranch': 'FugitiveHead',
                        \   'method': 'NearestMethodOrFunction',
                        \ },
                        \ }


endif

call plug#end()


" set statusline+=%F
