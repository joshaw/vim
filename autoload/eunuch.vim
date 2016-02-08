" Created:  Fri 12 Jun 2015
" Modified: Fri 05 Feb 2016
" Author:   Josh Wainwright
" Filename: eunuch.vim

let s:sep = has('win32') ? '\' : '/'

function! eunuch#RemoveFile(bang, args) abort
	if !empty(&buftype) || empty(bufname('%'))
		echo "No file to remove"
		return
	endif
	let file = expand('%')
	execute 'bwipeout' . a:bang
	if !bufloaded(file) && delete(file)
		echoerr 'Failed to delete "' . file . '"'
	else
		echo file "removed"
	endif
endfunction

function! eunuch#MoveFile(bang, args) abort
	let src = expand('%:p')
	let dst = empty(a:args) ? input('New file name: ', expand('%:p'), 'file')
				\ : expand(a:args)
	if isdirectory(dst) || dst[-1:-1] =~# '[\\/]'
		let dst .= (dst[-1:-1] =~# '[\\/]' ? '' : s:sep) . fnamemodify(src, ':t')
	endif
	if !isdirectory(fnamemodify(dst, ':h'))
		call mkdir(fnamemodify(dst, ':h'), 'p')
	endif
	let dst = substitute(simplify(dst), '^\.\'.s:sep, '', '')
	if !a:bang && filereadable(dst)
		exe 'keepalt saveas '.fnameescape(dst)
	elseif rename(src, dst)
		echoerr 'Failed to rename "' . src . '" to "' . dst . '"'
	else
		setlocal modified
		exe 'keepalt saveas! '.fnameescape(dst)
		if src !=# expand('%:p')
			execute 'bwipe '.fnameescape(src)
		endif
	endif
endfunction

function! eunuch#Grep(bang,args,prg) abort
	let grepprg = &l:grepprg
	let grepformat = &l:grepformat
	let shellpipe = &shellpipe
	try
		let &l:grepprg = a:prg
		setlocal grepformat=%f
		if &shellpipe ==# '2>&1| tee' || &shellpipe ==# '|& tee'
			let &shellpipe = '| tee'
		endif
		execute 'grep! '.a:args
		if empty(a:bang) && !empty(getqflist())
			return 'cfirst'
		else
			return ''
		endif
	finally
		let &l:grepprg = grepprg
		let &l:grepformat = grepformat
		let &shellpipe = shellpipe
	endtry
endfunction

function! eunuch#Mkdir(bang, args) abort
	call mkdir(empty(a:args) ? expand('%:h') : a:args, empty(a:bang) ? '' : 'p')
	if empty(a:args)
		silent keepalt execute 'file' expand('%')
	endif
endfunction

function! eunuch#MaxLine() abort
	let maxcol = 0
	let lnum = 1
	while lnum <= line('$')
		call cursor(lnum, 0)
		if col('$') > maxcol
			let maxcol = col('$')
			let maxline = lnum
		endif
		let lnum += 1
	endwhile
	exec maxline
	echo 'Line' maxline 'has' maxcol - 1 'characters'
endfunction

function! eunuch#FileSize(bang) abort
	let bytes = getfsize(expand("%:p"))
	if bytes < 0
		return
	endif
	if a:bang
		echo bytes
		return bytes
	endif
	let suf = ['B', 'KB', 'MB', 'GB']
	let n = 0
	while bytes > 1024
		let n += 1
		let bytes = bytes / 1024.0
	endwhile
	let fsize = printf('%.2f%s', bytes, suf[n])
	echo expand("%:p") fsize
	return fsize
endfunction
