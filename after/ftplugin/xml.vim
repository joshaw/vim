" Created:  Thu 20 Aug 2020
" Modified: Mon 15 Feb 2021
" Author:   Josh Wainwright
" Filename: xml.vim

if executable('xmllint')
	setlocal equalprg=xmllint\ --format\ --recover\ -
	setlocal formatexpr=Formatexpr_prg('xmllint\ --format\ --recover\ -')
endif
