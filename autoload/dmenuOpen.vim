" Created:  Wed 16 Apr 2014
" Modified: Thu 09 Jan 2020
" Author:   Josh Wainwright
" Filename: dmenuOpen.vim

" Find a file and pass it to cmd
function! dmenuOpen#DmenuOpen(cmd, ...) abort

	let l:global = a:0 > 0 ? a:1 : 0

	if l:global
		silent let foptions = systemlist('find ~ -type f 2> /dev/null')
	else
		silent let foptions = systemlist('git ls-files 2> /dev/null')
		if empty(foptions)
			silent let foptions = systemlist('find . -type f 2> /dev/null')
		endif
	endif

	silent let fnames = systemlist('dmenu -b -i -l 20 -p ' . a:cmd, foptions)
	if empty(fnames)
		return
	endif
	let fname = fnameescape(expand(fnames[0][0:-1]))
	if !filereadable(fname)
		return
	endif
	exe a:cmd . ' ' . fname
	call histadd('cmd', a:cmd . ' ' . fname)
endfunction
