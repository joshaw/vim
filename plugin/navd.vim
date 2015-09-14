" Created:  Tue 25 Aug 2015
" Modified: Mon 14 Sep 2015
" Author:   Josh Wainwright
" Filename: navd.vim

" ~/.vim/autoload/navd.vim

command! -nargs=? -bang Navd :call navd#navd(<q-args>, <bang>0)
command! -bang NavdBuf :call navd#navdbuf()

nnoremap <silent> - :Navd<cr>
nnoremap <silent> _ :NavdBuf<cr>

augroup navd_bufevents
  au!
  autocmd BufEnter * if isdirectory(expand('<amatch>'))
        \ | call navd#navd(expand('<amatch>'), 0)
        \ | endif
augroup END
