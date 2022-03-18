" Created:  Wed 04 Mar 2020
" Modified: Fri 18 Mar 2022
" Author:   Josh Wainwright
" Filename: sh.vim

if executable('shellcheck')
	setlocal makeprg=shellcheck\ -x\ -f\ gcc\ $*\ %:S
	setlocal errorformat=%f:%l:%c:\ %m
endif

if executable('split-cmd')
	setlocal formatprg=split-cmd
endif

setlocal keywordprg=help
