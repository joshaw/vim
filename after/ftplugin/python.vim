" Created:  Thu 09 Jul 2015
" Modified: Wed 17 Mar 2021
" Author:   Josh Wainwright
" Filename: python.vim

setlocal expandtab
setlocal keywordprg=pydoc

if executable('black')
	setlocal equalprg=black\ --quiet\ --fast\ -
"	setlocal makeprg=black\ --fast\ %
"	setlocal errorformat=error:\ cannot\ format\ %f:\ Cannot\ parse:\ %l:%c:\ %m
"	setlocal errorformat+=%-G%*\\d\ file\ failed\ to\ reformat.
"	setlocal errorformat+=%-G%*\\d\ file\ left\ unchanged.
"	setlocal errorformat+=%-GOh\ no%.%#
"	setlocal errorformat+=%-GAll\ done%.%#

	setlocal formatexpr=Formatexpr_prg('black\ --quiet\ --fast\ -')
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
