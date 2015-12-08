" Created:  Fri 04 Dec 2015
" Modified: Fri 04 Dec 2015
" Author:   Josh Wainwright
" Filename: seetags.vim

command! -nargs=* Seetags call seetags#seetags(<q-args>)
nnoremap + :Seetags<cr>
