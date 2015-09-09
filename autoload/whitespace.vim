" Created:  Wed 16 Apr 2014
" Modified: Mon 07 Sep 2015
" Author:   Josh Wainwright
" Filename: whitespace.vim
"
" Remove trailing spaces
function! whitespace#StripTrailing(firstl, lastl) range
" 	if &ft == 'markdown' || &ft == 'dat'
" 		return
" 	endif
	if stridx(&formatoptions, 'a') > 0
		return
	endif
	let w = winsaveview()
	let old_query = getreg("/")
	exe 'keeppatterns' a:firstl . ',' . a:lastl . 's/\s\+$//e'
	exe 'keeppatterns' a:firstl . ',' . (a:lastl-1) . 's/\n\{3,}/\r\r/e'
	call whitespace#TrimEndLines()
	call setreg('/', old_query)
	call winrestview(w)
endfunction

" Remove empty line at the end of file
function! whitespace#TrimEndLines()
	let w = winsaveview()
	keeppatterns %s#\($\n\s*\)\+\%$##e
	call winrestview(w)
endfunction
