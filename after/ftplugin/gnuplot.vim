" Created:  Mon 18 May 2015
" Modified: Fri 11 Sep 2015
" Author:   Josh Wainwright
" Filename: gnuplot.vim

if !filereadable("makefile")
	setlocal makeprg=gnuplot\ %
endif
