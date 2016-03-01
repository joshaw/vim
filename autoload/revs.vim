" Created:  Mon 29 Feb 2016
" Modified: Mon 29 Feb 2016
" Author:   Josh Wainwright
" Filename: revs.vim

function! revs#gitLog(filename)
	let cmd = 'git log --pretty=format:"%h - %ar : %s" '. a:filename
	let logcontents = systemlist(cmd)
	call s:list2buffer(logcontents)
	call s:keybindings(a:filename)
endfunction

function! s:gitshow_commit(filename, line) abort
	let commit = substitute(a:line, '\s.*', '', '')
	let cmd = 'git show ' . commit . ':' . a:filename
	let filecontents = systemlist(cmd)
	let filecontents = systemlist('git show --quiet ' . commit) + [''] + filecontents
	call s:list2buffer(filecontents)
endfunction

function! s:keybindings(filename)
	exe 'nnoremap <buffer> <cr> :call <SID>gitshow_commit("'. a:filename . '", getline("."))<cr>'
	nnoremap <buffer> q :call <SID>quit()<cr>
endfunction

function! s:quit()
	%delete _
	buf #
endfunction

function! s:list2buffer(list)
	call ScratchBuf()
	call append(0, a:list)
	$delete _
	call cursor(1, 1)
	filetype detect
endfunction
