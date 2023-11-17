"
"autocmd Filetype markdown inoremap <buffer> <silent> ;, <++>
"autocmd Filetype markdown inoremap <buffer> <silent> ;f <Esc>/<++><CR>:nohlsearch<CR>c4l
"autocmd Filetype markdown nnoremap <buffer> <silent> ;f <Esc>/<++><CR>:nohlsearch<CR>c4l
"autocmd Filetype markdown inoremap <buffer> <silent> ;s <Esc>/ <++><CR>:nohlsearch<CR>c5l
"autocmd Filetype markdown inoremap <buffer> <silent> ;- ---<Enter><Enter>
"autocmd Filetype markdown inoremap <buffer> <silent> ;b **** <++><Esc>F*hi
"autocmd Filetype markdown inoremap <buffer> <silent> ;x ~~~~ <++><Esc>F~hi
"autocmd Filetype markdown inoremap <buffer> <silent> ;x ** <++><Esc>F*i
"autocmd Filetype markdown inoremap <buffer> <silent> ;q `` <++><Esc>F`i
"autocmd Filetype markdown inoremap <buffer> <silent> ;c ```<Enter><++><Enter>```<Enter><Enter><++><Esc>4kA
"autocmd Filetype markdown inoremap <buffer> <silent> ;g - [ ] <Enter><++><ESC>kA
"autocmd Filetype markdown inoremap <buffer> <silent> ;u <u></u><++><Esc>F/hi
"autocmd Filetype markdown inoremap <buffer> <silent> ;p ![](<++>) <Enter><++><Esc>kF[a
"autocmd Filetype markdown inoremap <buffer> <silent> ;a [](<++>) <++><Esc>F[a
"autocmd Filetype markdown inoremap <buffer> <silent> ;1 #<Space><Enter><++><Esc>kA
"autocmd Filetype markdown inoremap <buffer> <silent> ;2 ##<Space><Enter><++><Esc>kA
"autocmd Filetype markdown inoremap <buffer> <silent> ;3 ###<Space><Enter><++><Esc>kA
"autocmd Filetype markdown inoremap <buffer> <silent> ;4 ####<Space><Enter><++><Esc>kA
"autocmd Filetype markdown inoremap <buffer> <silent> ;t <C-R>=strftime("%Y-%m-%d %H:%M:%S")<CR>



" convert charset
" autocmd Filetype * set nobomb | set fenc=utf8 

" Copy search matches
" g/pattern/yank A

" Capitalize first letter of each word in a selection using Vim
" '<,'>s/\v<(.)(\w*)/\u\1\L\2/g | noh 

" command! -nargs=0 CapWords :'<,'>s/\v<(.)(\w*)/\u\1\L\2/g | noh

