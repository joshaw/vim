" Created:  Wed 16 Apr 2014
" Modified: Fri 20 Nov 2015
" Author:   Josh Wainwright
" Filename: java.vim

" set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
setlocal errorformat=%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#

let java_highlight_functions='style'
let java_highlight_java_lang_ids=1

setlocal noautochdir
