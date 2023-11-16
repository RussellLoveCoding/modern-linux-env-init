"""""""""""""""""""""
" autocmd
autocmd BufWritePost ~/.config/nvim/autocmd.vim source ~/.config/nvim/autocmd.vim 
"command define 


"""""""""""""""""""""
" autocmd
" autocmd Filetype markdown inoremap <buffer> <silent> ;, <++>
" autocmd Filetype markdown inoremap <buffer> <silent> ;f <Esc>/<++><CR>:nohlsearch<CR>c4l
" autocmd Filetype markdown nnoremap <buffer> <silent> ;f <Esc>/<++><CR>:nohlsearch<CR>c4l
" autocmd Filetype markdown inoremap <buffer> <silent> ;s <Esc>/ <++><CR>:nohlsearch<CR>c5l
" autocmd Filetype markdown inoremap <buffer> <silent> ;- ---<Enter><Enter>
" autocmd Filetype markdown inoremap <buffer> <silent> ;b **** <++><Esc>F*hi
" autocmd Filetype markdown inoremap <buffer> <silent> ;x ~~~~ <++><Esc>F~hi
" autocmd Filetype markdown inoremap <buffer> <silent> ;x ** <++><Esc>F*i
" autocmd Filetype markdown inoremap <buffer> <silent> ;q `` <++><Esc>F`i
" autocmd Filetype markdown inoremap <buffer> <silent> ;c ```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA
" autocmd Filetype markdown inoremap <buffer> <silent> ;g - [ ] <Enter><++><ESC>kA
" autocmd Filetype markdown inoremap <buffer> <silent> ;u <u></u><++><Esc>F/hi
" autocmd Filetype markdown inoremap <buffer> <silent> ;p ![](<++>) <Enter><++><Esc>kF[a
" autocmd Filetype markdown inoremap <buffer> <silent> ;a [](<++>) <++><Esc>F[a
" autocmd Filetype markdown inoremap <buffer> <silent> ;1 #<Space><Enter><++><Esc>kA
" autocmd Filetype markdown inoremap <buffer> <silent> ;2 ##<Space><Enter><++><Esc>kA
" autocmd Filetype markdown inoremap <buffer> <silent> ;3 ###<Space><Enter><++><Esc>kA
" autocmd Filetype markdown inoremap <buffer> <silent> ;4 ####<Space><Enter><++><Esc>kA
" autocmd Filetype markdown inoremap <buffer> <silent> ;t <C-R>=strftime("%Y-%m-%d %H:%M:%S")<CR>
" 


" convert charset
" autocmd Filetype * set nobomb | set fenc=utf8 

" Copy search matches
" g/pattern/yank A


"""""""""""""""""""""
" formatter
" convert rows of numbers or text (as if pasted from excel column) to an array
" function! ToArrayFunction() range
" silent execute a:firstline . "," . a:lastline . "s/^/'/"
" silent execute a:firstline . "," . a:lastline . "s/$/',/"
" silent execute a:firstline . "," . a:lastline . "join"
" " these two lines below are different by only one character!
" silent execute "normal I["
" silent execute "normal $xa]"
" endfunction
" command! -range ToArray <line1>,<line2> call ToArrayFunction()
" 
" Capitalize first letter of each word in a selection, two cases:
" AAAAAAAAAAAA 
" 'AAA BBB' => 'Aaa Bbb',
" 'aaa bbb' => 'Aaa Bbb'
command! -nargs=0 Camel :'<,'>s/\v<(.)(\w*)/\u\1\L\2/g | noh 

