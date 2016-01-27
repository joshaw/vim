" Created:  Mon 25 Jan 2016
" Modified: Mon 25 Jan 2016
" Author:   Josh Wainwright
" Filename: scratch.vim

function! ScratchBuf()
	call scratch#scratch()
endfunction

function! ScratchBufHere()
	call scratch#scratch(0)
endfunction
