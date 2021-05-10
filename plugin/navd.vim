" Created:  Tue 25 Aug 2015
" Modified: Tue 11 Feb 2020
" Author:   Josh Wainwright
" Filename: navd.vim

" ~/.vim/autoload/navd.vim

command! -nargs=? -bar -bang -complete=file Navd :call navd#navd(<q-args>, <bang>0)
command! -nargs=? -bar -bang -complete=dir NavdRecursive :call navd#navdall(<q-args>, <bang>1)
command! -nargs=0 NavdBuf :call navd#navdbufs()

"nnoremap <silent> - :Navd %:p:h/<cr>
"nnoremap <silent> _ :NavdBuf<cr>

augroup navd_bufevents
  au!
"   autocmd VimEnter,BufNew * if isdirectory(expand('<amatch>')) | Navd <amatch> | endif
"   autocmd VimEnter,BufNew * :call navd#navd(expand("<amatch>"), 0)
  autocmd BufEnter * if isdirectory(expand('%')) | exe 'Navd %' | endif
augroup END

