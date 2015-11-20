" Created:  Wed 16 Apr 2014
" Modified: Fri 20 Nov 2015
" Author:   Josh Wainwright
" Filename: dmenuOpen.vim

" Find a file and pass it to cmd
function! dmenuOpen#DmenuOpen(cmd, ...) abort

	let l:global = a:0 > 0 ? a:1 : 0
	let l:amhome = getcwd() == $HOME
	let l:filesfile = '~/.files'

	if (l:global || l:amhome) && filereadable(expand(l:filesfile))
		let command = 'cat ' . l:filesfile
	elseif exists('b:git_dir') && b:git_dir !=# ''
		let command = 'cd '. fnamemodify(b:git_dir, ':h') .'; git ls-files'
	elseif executable('lsall')
		let command = 'lsall -n'
	elseif executable('ag')
		let command = 'ag --hidden -g \"\"'
	else
		let command = 'find *'
	endif
	
	let fname = systemlist(command . ' | dmenu -b -i -l 20 -p ' . a:cmd)[0]
	let fname = fnameescape(fname)
	if empty(fname) || !filereadable(expand(fname))
		echo 'No file selected'
		return
	endif
	execute a:cmd . ' ' . fname
	call histadd('cmd', a:cmd . ' ' . fname)
endfunction
