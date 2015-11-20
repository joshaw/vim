" Created:  Mon 18 May 2015
" Modified: Fri 20 Nov 2015
" Author:   Josh Wainwright
" Filename: gnuplot.vim

if !filereadable('makefile')
	setlocal makeprg=gnuplot\ %
endif
