" Created:  Mon 15 Feb 2016
" Modified: Wed 16 Mar 2016
" Author:   Josh Wainwright
" Filename: navd.vim

if exists('b:current_syntax')
	finish
endif

syntax match NavdHead '\v^.*\/\ze[^\/]+\/?$' conceal
syntax match NavdPath '\v[^\/]+\/$'
syntax match NavdHead '^\w ' conceal
syntax match NavdNoWrite '^w .*$' contains=NavdHead
syntax match NavdMod '^m .*$' contains=NavdHead
syntax match NavdCurDir '\%^.*$'

highlight! link NavdPath    Directory
highlight! link NavdNoWrite String
highlight! link NavdMod     Keyword
highlight! link NavdCurDir  SpecialComment

let b:current_syntax = 'navd'
