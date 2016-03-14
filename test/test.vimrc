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

	if type(a:one) == type("")
		echo a:one
		echo a:two
	elseif type(a:one) == type([])
		echo "['" . a:one[0] . "',"
		for i in a:one[1:-2]
			echo " '" . i . "',"
		endfor
		echo " '" . a:one[-1] . "']"
		echo "['" . a:two[0] . "',"
		for i in a:two[1:-2]
			echo " '" . i . "',"
		endfor
		echo " '" . a:two[-1] . "']"
	endif
endfunction
