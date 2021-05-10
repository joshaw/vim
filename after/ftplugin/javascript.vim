" Created:  Thu 07 Jan 2021
" Modified: Thu 07 Jan 2021
" Author:   Josh Wainwright
" Filename: javascript.vim

if executable('js-beautify')
	setlocal equalprg=js-beautify\ -w\ 88\ -n\ -b\ collapse,preserve-inline\ -
endif
