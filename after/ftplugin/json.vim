" Created:  Thu 20 Aug 2020
" Modified: Tue 14 Mar 2023
" Author:   Josh Wainwright
" Filename: json.vim

if executable('jq')
	setlocal formatprg=jq\ .
endif
