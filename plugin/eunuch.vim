" eunuch.vim - Helpers for UNIX
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      1.1

if exists('g:loaded_eunuch') || &cp || v:version < 700
  finish
endif
let g:loaded_eunuch = 1

command! -bar -bang RemoveFile :call eunuch#RemoveFile(<q-bang>, <q-args>)
command! -bar -bang -nargs=? -complete=file MoveFile :call eunuch#MoveFile(<q-bang>, <q-args>)
command! -bar -bang -nargs=+ -complete=file Find   :call eunuch#Grep(<q-bang>, <q-args>, 'find')
command! -bar -bang -nargs=+ -complete=file Locate :call eunuch#Grep(<q-bang>, <q-args>, 'locate')
command! -bar -bang -nargs=+ -complete=file GGrep :call eunuch#Grep(<q-bang>, <q-args>, 'git grep')
command! -bar -bang -nargs=? -complete=dir Mkdir :call eunuch#Mkdir(<q-bang>, <q-args>)
command! -bar -nargs=0 MaxLine call eunuch#MaxLine()
command! -bar -bang -nargs=0 FileSize call eunuch#FileSize(<bang>0)

" vim:set sw=2 sts=2:
