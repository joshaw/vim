" Created:  Mon 15 Feb 2016
" Modified: Sat 27 Feb 2016
" Author:   Josh Wainwright
" Filename: navd.vim

" Syntax highlighting of folders
syntax clear
syntax match NavdHead '\v^\s*\zs.*\/\ze[^\/]+\/?$' conceal
syntax match NavdPath '\v[^\/]+\/$'
syntax match NavdHead '^\w ' conceal
syntax match NavdNoWrite '^w .*$' contains=NavdHead
syntax match NavdMod '^m .*$' contains=NavdHead
syntax match NavdCurDir '\%^.*$'
highlight! link NavdPath    Directory
highlight! link NavdNoWrite String
highlight! link NavdMod     Keyword
highlight! link NavdCurDir  SpecialComment
