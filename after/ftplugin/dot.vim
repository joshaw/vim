" Created:  Wed 04 Nov 2015
" Modified: Fri 20 Nov 2015
" Author:   Josh Wainwright
" Filename: dot.vim

if !filereadable('makefile')
	setlocal makeprg=dot\ %\ -O\ -Tpdf
endif
