" Created:  Wed 04 Mar 2020
" Modified: Wed 17 Mar 2021
" Author:   Josh Wainwright
" Filename: sh.vim

if executable('shellcheck')
	setlocal makeprg=shellcheck\ -x\ -f\ gcc\ $*\ %:S
	setlocal errorformat=%f:%l:%c:\ %m
endif

setlocal keywordprg=help
