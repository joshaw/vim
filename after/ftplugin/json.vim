" Created:  Thu 20 Aug 2020
" Modified: Mon 15 Feb 2021
" Author:   Josh Wainwright
" Filename: json.vim

if executable('jq')
	setlocal equalprg=jq\ -S\ .
	setlocal formatexpr=Formatexpr_prg('jq\ -S\ .')
endif
