" Created:  Thu 09 Jul 2015
" Modified: Tue 30 Jan 2024
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

	if !exists("$BLACK_LINE_LENGTH")
		let $BLACK_LINE_LENGTH=88
	endif
	setlocal formatprg=black\ --quiet\ --fast\ --line-length=$BLACK_LINE_LENGTH\ -
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
