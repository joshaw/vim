" Created:  Wed 04 Mar 2020
" Modified: Thu 14 Apr 2022
" Author:   Josh Wainwright
" Filename: sh.vim

if executable('shellcheck')
	setlocal makeprg=shellcheck\ -x\ -f\ gcc\ $*\ %:S
	setlocal errorformat=%f:%l:%c:\ %m
endif

if executable('shfmt')
	setlocal formatprg=shfmt
endif

setlocal keywordprg=help
