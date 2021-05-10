" Sorts blocks of lines using the indentation of the first line as the block
" delimiter. Useful for sorting things like yaml dicts where the indentation
" represents different keys.
function! Block_sort() range abort
	let indent = substitute(getline('.'), '\(\s\+\).*', '\1', '')
	'>put ='END_OF_RANGE'
	exe "silent '<+1,'>substitute/^\\(" . indent . "\\S\\)/SORT_LINE\\1/"
	silent '<+1,'>vglobal/SORT_LINE/substitute/^/SOL_MARKER/
	'<,'>join!
	silent '<,'>substitute/SORT_LINE/\r/g
	'<,/^END_OF_RANGE$/sort
	silent '<,/^END_OF_RANGE$/substitute/SOL_MARKER/\r/ge
	/^END_OF_RANGE$/delete
endfunction
