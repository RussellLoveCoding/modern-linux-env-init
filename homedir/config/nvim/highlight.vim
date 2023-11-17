autocmd BufWritePost ~/.config/nvim/highlight.vim source ~/.config/nvim/highlight.vim 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" highlight groups

"""""""""""""""""""""
" highlight group && colorschme
" COLORSCHEME_MARKER

" 必须在 colorscheme 定义前定义，
" 不懂为啥在quick-scope 处定义无法生效
" set guicursor=
" augroup qs_colors
" autocmd!
" " " autocmd ColorScheme * highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
" " " autocmd ColorScheme * highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline
" if !exists('g:vscode')
" autocmd ColorScheme * highlight QuickScopePrimary gui=underline,bold guifg=ctermfg guibg=#282828 ctermfg=155 cterm=underline
" autocmd ColorScheme * highlight QuickScopeSecondary gui=underline,bold guifg=ctermfg guibg=#282828 ctermfg=81 cterm=underline
" else
" autocmd ColorScheme * highlight QuickScopePrimary gui=underline,bold guifg=ctermfg ctermfg=155 cterm=underline
" autocmd ColorScheme * highlight QuickScopeSecondary gui=underline,bold guifg=ctermfg ctermfg=81 cterm=underline
" endif
" augroup END

" inline git blame color
highlight Blamer guifg=#61574c

" quick-scope
highlight QuickScopePrimary gui=underline,bold guifg=ctermfg guibg=#282828 ctermfg=155 cterm=underline
highlight QuickScopeSecondary gui=underline,bold guifg=ctermfg guibg=#282828 ctermfg=81 cterm=underline

" git diff
hi DiffAdd        ctermfg=142 ctermbg=235 gui=none guifg=ctermfg guibg=#3e563e
hi DiffChange     ctermfg=108 ctermbg=235 gui=none guifg=ctermfg guibg=#2c3435
hi DiffDelete     ctermfg=167 ctermbg=235 gui=none guifg=#3a3030 guibg=#3a3030
hi DiffText       ctermfg=214 ctermbg=235 gui=none guifg=ctermfg guibg=#005967
" hi DiffText       ctermfg=214 ctermbg=235 gui=none guifg=ctermfg guibg=#044954

" basic
" hi CursorLine cterm=reverse ctermbg=241 gui=reverse 
hi Cursor cterm=reverse ctermbg=241 gui=reverse 
hi lCursor cterm=reverse ctermbg=241 gui=reverse 
hi Visual cterm=none ctermbg=240 gui=none guibg=#384539
hi CursorColumn cterm=reverse ctermbg=241 gui=none guifg=ctermfg guibg=#384539
hi Search gui=none guifg=ctermfg guibg=#5d4d2a

" while reverse highlight for cursor doesn't take effect, add the following line
" to windows terminal settings to achieve green cursor, avoiding white color
" obscuring character under cursor.
" cursorShape": "filledBox",
" cursorColor": "#45902e",  // 选一个高亮方案里不常见到的颜色，这里我选的深绿色
" cursorTextColor": "textForeground"
