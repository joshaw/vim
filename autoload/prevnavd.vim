" Created:  Tue 26 Jan 2016
" Modified: Tue 26 Jan 2016
" Author:   Josh Wainwright
" Filename: prevnavd.vim

function! prevnavd#PrevNavd(dir) abort
	call ScratchBuf()
	if !isdirectory(a:dir)
		let dir = fnamemodify(a:dir, ':h')
	else
		let dir = a:dir
	endif
" 	let list = systemlist("find " . dir . ' -maxdepth 1')
	let list = systemlist("find " . dir . ' -maxdepth 1 \( -type d -printf "%p/\n" , -type f -print \)')
	let list = list[1:-1]
	call setline(1, list)
	nnoremap <buffer> <cr> :call prevnavd#PrevNavd(getline('.'))<cr>
	nnoremap <buffer> - :call prevnavd#PrevNavd(<SID>getparent(getline('.')))<cr>
" 	setlocal updatetime=250
" 	autocmd CursorHold <buffer> call <SID>preview(getline('.'))
	autocmd CursorMoved <buffer> call <SID>preview(getline('.'))
	let curfile = getline('.')
	call s:preview(curfile)
endfunction

function! s:getparent(file)
	echo a:file
	if a:file[-1:-1] ==# '/'
		let file = a:file[0:-2]
	else
		let file = a:file
	endif
	let file = fnamemodify(file, ':p:h')
	echo file
	return file
endfunction

function! s:preview(file)
	let file = fnameescape(a:file)
	if tabpagewinnr(1, '$') != 2
		vnew
	endif
	wincmd l
	wincmd =
	%delete _
	if filereadable(a:file)
		call setline(1, readfile(a:file, '', 100))
	elseif isdirectory(a:file)
		call setline(1, systemlist("tree -L 1 " . file))
	endif
	wincmd h
endfunction
