" Created:  Mon 14 Mar 2016
" Modified: Mon 14 Mar 2016
" Author:   Josh Wainwright
" Filename: test.vimrc

set nocompatible
set verbosefile=output.log
set shortmess=aoOsWAIc

function! Assert_print(one, two) abort
	if type(a:one) !=# type(a:two)
		echoerr "Types do not match"
	endif

	if a:one ==# a:two
		return
	endif

	if type(a:one) == type("")
		call add(v:errors, a:one)
		call add(v:errors, a:two)
	elseif type(a:one) == type([])
		call add(v:errors, "=====")
		call add(v:errors, "['" . a:one[0] . "',")
		for i in a:one[1:-2]
			call add(v:errors, " '" . i . "',")
		endfor
		call add(v:errors, " '" . a:one[-1] . "']")

		call add(v:errors, "=====")

		call add(v:errors, "['" . a:two[0] . "',")
		for i in a:two[1:-2]
			call add(v:errors, " '" . i . "',")
		endfor
		call add(v:errors, " '" . a:two[-1] . "']")
		call add(v:errors, "=====")
	endif
endfunction
