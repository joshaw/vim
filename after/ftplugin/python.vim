" Created:  Thu 09 Jul 2015
" Modified: Tue 14 Mar 2023
" Author:   Josh Wainwright
" Filename: python.vim

 let g:pyindent_open_paren = 'shiftwidth()'
 let g:pyindent_nested_paren = 'shiftwidth()'
 let g:pyindent_continue = 'shiftwidth()'

setlocal expandtab
setlocal keywordprg=pydoc

if executable('black')
"	setlocal makeprg=black\ --fast\ %
"	setlocal errorformat=error:\ cannot\ format\ %f:\ Cannot\ parse:\ %l:%c:\ %m
"	setlocal errorformat+=%-G%*\\d\ file\ failed\ to\ reformat.
"	setlocal errorformat+=%-G%*\\d\ file\ left\ unchanged.
"	setlocal errorformat+=%-GOh\ no%.%#
"	setlocal errorformat+=%-GAll\ done%.%#

	setlocal formatprg=black\ --quiet\ --fast\ -
endif

if executable('pylint')
	set makeprg=pylint\ --reports=n\ --output-format=parseable\ %:p
	set errorformat=%f:%l:\ %m
	" ignores anything that doesn't match format above
	setlocal errorformat+=%-G%.%#
endif

if executable('pydoc3')
	setlocal keywordprg=pydoc3
endif
