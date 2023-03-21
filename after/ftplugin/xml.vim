" Created:  Thu 20 Aug 2020
" Modified: Tue 14 Mar 2023
" Author:   Josh Wainwright
" Filename: xml.vim

if executable('xmllint')
	setlocal formatexpr=xmllint\ --format\ --recover\ -
endif
