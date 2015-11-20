" Created:  Thu 24 Jul 2014
" Modified: Fri 20 Nov 2015
" Author:   Josh Wainwright
" Filename: tex.vim

" setlocal iskeyword+=:,-,_
let g:tex_isk='48-57,a-z,A-Z,192-255,:,-,_'
setlocal makeprg=make
setlocal keywordprg=define

" Standard error message formats
" Note: We consider statements that starts with "!" as errors
setlocal errorformat=%E!\ LaTeX\ %trror:\ %m
setlocal errorformat+=%E%f:%l:\ %m
setlocal errorformat+=%E!\ %m

" More info for undefined control sequences
setlocal errorformat+=%Z<argument>\ %m

" More info for some errors
setlocal errorformat+=%Cl.%l\ %m

" Parse biblatex warnings
setlocal errorformat+=%-C(biblatex)%.%#in\ t%.%#
setlocal errorformat+=%-C(biblatex)%.%#Please\ v%.%#
setlocal errorformat+=%-C(biblatex)%.%#LaTeX\ a%.%#
setlocal errorformat+=%-Z(biblatex)%m

" Parse hyperref warnings
setlocal errorformat+=%-C(hyperref)%.%#on\ input\ line\ %l.

" setlocal errorformat+=%+WLaTeX\ %.%#Warning:\ %.%#line\ %l%.%#
" setlocal errorformat+=%+W%.%#\ at\ lines\ %l--%*\\d
" setlocal errorformat+=%+WLaTeX\ %.%#Warning:\ %m
" setlocal errorformat+=%+W%.%#Warning:\ %m

" setlocal errorformat+=%-WLaTeX\ %.%#Warning:\ %.%#line\ %l%.%#
setlocal errorformat+=%-W%.%#\ at\ lines\ %l--%*\\d
setlocal errorformat+=%-WLaTeX\ %.%#Warning:\ %m
setlocal errorformat+=%-W%.%#Warning:\ %m

" Push file to file stack
setlocal errorformat+=%+P**%f
setlocal errorformat+=%+P**\"%f\"

" Ignore unmatched lines
setlocal errorformat+=%-G%.%#
