" Created:  Tue 25 Aug 2015
" Modified: Tue 26 Jan 2016
" Author:   Josh Wainwright
" Filename: navd.vim

" ~/.vim/autoload/navd.vim

command! -nargs=? -bar -bang -complete=file Navd :call navd#navd(<q-args>, <bang>0)
command! -bang NavdBuf :call navd#navdbufs()
command! NavdRecursive :call navd#navdall()

nnoremap <silent> - :Navd<cr>
nnoremap <silent> _ :NavdBuf<cr>

augroup navd_bufevents
  au!
  autocmd VimEnter,BufNew * if isdirectory(expand('<amatch>')) | Navd | endif
augroup END
