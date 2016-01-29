" Created:  Tue 25 Aug 2015
" Modified: Fri 29 Jan 2016
" Author:   Josh Wainwright
" Filename: navd.vim

" ~/.vim/autoload/navd.vim

command! -nargs=? -bar -bang -complete=file Navd :call navd#navd(<q-args>, <bang>0)
command! -bang NavdBuf :call navd#navdbufs()
command! NavdRecursive :call navd#navdall()

nnoremap <silent> - :Navd %:p:h<cr>
nnoremap <silent> _ :NavdBuf<cr>

augroup navd_bufevents
  au!
  autocmd VimEnter,BufNew * if isdirectory(expand('<amatch>')) | Navd <amatch> | endif
augroup END
