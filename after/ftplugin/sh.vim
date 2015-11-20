" Created:  Wed 21 Jan 2015
" Modified: Fri 20 Nov 2015
" Author:   Josh Wainwright
" Filename: sh.vim

iabbrev <buffer> <expr> #! GetShebang()
let g:is_bash=1

function! GetShebang()
	let s:shebang = ['\#!/bin/bash',
	                \ substitute(CreatedHeader(),'^','# ','g'),
	                \ '']
	return join(s:shebang, "\<esc>o")
endfunction
