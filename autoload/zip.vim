" Created:  Wed 17 Feb 2016
" Modified: Wed 17 Feb 2016
" Author:   Josh Wainwright
" Filename: zip.vim

function! zip#zip(fname)
	let list = systemlist("zipinfo -1 '" . a:fname . "'")
	call append(0, fnamemodify(a:fname, ':~:.'))
	call append(1, list)
	$delete _
	call cursor(1, 1)
	setlocal nomodified
	setfiletype navd
	let b:fname = a:fname
	nnoremap <silent><buffer> <cr> :call <SID>enter()<cr>
endfunction

function! s:enter()
	if line('.') == 1
		return
	endif
	let line = getline('.')
	let fnametail = fnamemodify(line, ':t')
	if empty(fnametail)
		return
	endif

	let fcontents = systemlist("unzip -p '" . b:fname . "' '" . line . "'")

	let tmpname = tempname() . '.' . fnametail
	call writefile(fcontents, tmpname, 'b')
	exe 'edit' fnameescape(tmpname)
	call cursor(1, 1)
	setlocal nomodified
endfunction
