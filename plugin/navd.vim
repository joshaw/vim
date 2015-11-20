" Created:  Tue 25 Aug 2015
" Modified: Fri 20 Nov 2015
" Author:   Josh Wainwright
" Filename: navd.vim

" ~/.vim/autoload/navd.vim

command! -nargs=? -bar -bang -complete=file Navd :call navd#navd(<q-args>, <bang>0)
command! -bang NavdBuf :call navd#navdbuf()
command! NavdRecursive :call navd#navdall()

nnoremap <silent> - :Navd<cr>
nnoremap <silent> _ :NavdBuf<cr>

augroup navd_bufevents
  au!
  autocmd VimEnter,BufNew * if isdirectory(expand('<amatch>')) | Navd | endif
augroup END
