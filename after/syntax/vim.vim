" Created:  Tue 22 Sep 2015
" Modified: Fri 20 Nov 2015
" Author:   Josh Wainwright
" Filename: vim.vim

if exists(':FT')
	syn region vimIsCommand matchgroup=vimCommand start="^\s*FT" end="$" contained
endif
