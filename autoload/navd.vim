" Created:  Tue 25 Aug 2015
" Modified: Mon 08 Feb 2016
" Author:   Josh Wainwright
" Filename: navd.vim

" Return 1 if the path ends in a slash, indicating it is a directory
function! s:isdir(path) abort
	return (a:path[-1:] ==# '/') "3x faster than isdirectory().
endfunction

" Convert back slashes to forward and remove repeated slashes
function! s:tounix(path) abort
	return substitute(a:path, '\\\+\|/\+', '/', 'g')
endfunction

" Return the sort index for the two paths
function! s:sort_paths(p1, p2) abort
	let l:isdir1 = s:isdir(a:p1)
	let l:isdir2 = s:isdir(a:p2)
	if l:isdir1 && !l:isdir2
		return -1
	elseif !l:isdir1 && l:isdir2
		return 1
	endif
	return a:p1 ==# a:p2 ? 0 : a:p1 ># a:p2 ? 1 : -1
endfunction

" Return the list of files and folders to display in the buffer.
function! s:get_paths(path, hidden) abort
	let paths = glob(a:path . '*', 1, 1)
	if a:hidden
		" Include hidden files except '.' and '..'
		let paths += glob(a:path . '.[^.]*', 1, 1)
	endif
	let paths = map(paths, "fnamemodify(v:val, ':p')")
	return sort(paths, '<sid>sort_paths')
endfunction

" Create a new file or folder depending on the name given.
function! s:new_obj() abort
	let curdir = getline(1)
	let new_name = input('Name: ')
	let new_obj = s:tounix(curdir . '/' . new_name)
	if s:isdir(new_name)
		if isdirectory(new_obj)
			echo 'Directory already exists: ' . new_name
			call search(new_obj, 'cw')
		else
			if mkdir(new_obj)
				call s:display_paths(curdir, new_name, b:navd['hidden'], curdir)
			else
				echoerr 'Failed to create directory: ' . new_name
				return
			endif
		endif
	else
		exe 'edit ' . new_obj
	endif
endfunction

function! s:get_obj_info() abort
	let path = fnamemodify(getline('.'), ':p')
	if isdirectory(path)
		let path = shellescape(path)
		let infostr = systemlist('du -sh ' . path)[0]
	else
		let path = shellescape(path)
		let infostr = systemlist('ls -Gghmn --time-style=+"" ' . path)[0]
	endif
	echo infostr
endfunction

function! s:toggle_hidden(curline) abort
	let b:navd['hidden'] = !b:navd['hidden']
	echo (b:navd['hidden'] == 1 ? 'S' : 'Not s') . 'howing hidden files'
	let curpath = getline(1)
	call s:display_paths(curpath, getline('.'), b:navd['hidden'], curpath)
endfunction

function! s:enter() abort
	let path = fnamemodify(getline('.'), ':p')
	if filereadable(path)
		exe 'edit' fnameescape(path)
	elseif isdirectory(path)
		call s:display_paths(path, 0, b:navd['hidden'], path)
	else
		echo 'Cannot access' path
	endif
endfunction

function! s:parent()
	let path = fnamemodify(getline(1), ':p:h:h') . '/'
	let cursor = getline(1)
	call s:display_paths(path, cursor, b:navd['hidden'], path)
endfunction

function! s:refresh()
	let path = getline(1)
	let cursor = getline('.')
	call s:display_paths(path, cursor, b:navd['hidden'], path)
endfunction

" Quit navd and return to previously edited file
function! s:quit_navd() abort
	let l:alt = bufnr('#')
	if l:alt < 0 || bufnr('$') == 1
		enew
	elseif l:alt == bufnr('%')
		buffer 1
	else
		exe 'buffer' l:alt
	endif
endfunction

" Pipe file through less or dir through tree to see preview
function! s:preview() abort
	let path = getline('.')
	if filereadable(path)
		silent exe "!less " . shellescape(path)
	elseif isdirectory(path)
		silent exe "!tree " . shellescape(path) . ' | less -R'
	endif
	redraw!
endfunction

" Setup the navd buffer, write the paths to it and make it unwritable.
function! s:setup_navd_buf(fs, paths, cursor) abort
	call ScratchBufHere()

	if !exists('b:navd')
		let b:navd = {'hidden': 0}
	endif

	setlocal concealcursor=nc conceallevel=3 undolevels=-1  noswapfile nowrap
	setlocal nobuflisted nolist cursorline colorcolumn=""  foldcolumn=0
	setlocal nofoldenable

	" Keybindings in navd buffer
	if a:fs
		nnoremap <silent><buffer> - :call <SID>parent()<cr>
		nnoremap <silent><buffer> <space> :call <SID>preview()<cr>
		nnoremap <silent><buffer> R :call <SID>refresh()<cr>
		nnoremap <silent><buffer> s :call <SID>toggle_hidden(getline('.'))<cr>
		nnoremap <silent><buffer> gh :call <SID>display_paths($HOME, 0, b:navd['hidden'], $HOME)<cr>
		nnoremap <silent><buffer> gs :call <SID>get_obj_info()<cr>
		xnoremap <silent><buffer> gs :call <SID>get_obj_info()<cr>
		nnoremap <silent><buffer> + :call <SID>new_obj()<cr>
	else
		nmapclear <buffer>
	endif
	nnoremap <silent><buffer> <cr> :call <SID>enter()<cr>
	nnoremap <silent><buffer> q :call <SID>quit_navd()<cr>
	nnoremap <silent><buffer> <esc> :call <SID>quit_navd()<cr>

	" Syntax highlighting of folders
	syntax clear
	syntax match NavdHead '\v.*\/\ze[^\/]+\/?$' conceal
	syntax match NavdPath '\v[^\/]+\/$'
	syntax match NavdHead '^\w ' conceal
	syntax match NavdNoWrite '^w .*$' contains=NavdHead
	syntax match NavdMod     '^m .*$' contains=NavdHead
	syntax match NavdCurDir  '\%^.*$'
	highlight! link NavdPath    Directory
	highlight! link NavdNoWrite String
	highlight! link NavdMod     Keyword
	highlight! link NavdCurDir  SpecialComment

	setlocal modifiable
	call append(0, a:paths)
	silent $delete _
	setlocal nomodifiable

	" Find the correct line to highlight
	call cursor(2, 1)
	if !empty(a:cursor)
		call search('\V' . a:cursor, 'cw')
	endif
endfunction

" Call the functions, sort out where we've come from and highlight that line.
function! s:display_paths(path, cursor, hidden, curpath) abort
	let target_path = fnamemodify(a:path, isdirectory(a:path) ? ':p' : ':p:h')
	
	" Add slash to end if not present
	let target_path = s:tounix(target_path . '/')
	let cursor = empty(a:cursor) ? a:cursor : s:tounix(a:cursor)

	" Check if target name is hidden and show hidden if true
	let tail = fnamemodify(cursor, s:isdir(cursor) ? ':h:t' : ':t')
	if tail[0] ==# '.' && strlen(tail) > 1
		let hidden = 1
	else
		let hidden = a:hidden
	endif

	let paths = s:get_paths(target_path, hidden)
	call insert(paths, a:curpath)
	call s:setup_navd_buf(1, paths, cursor)
endfunction

function! navd#navdbufs() abort
	let l:tot_bufs = bufnr('$')
	if l:tot_bufs == 1 && bufname(1) ==# ''
		return
	endif
	let paths = []
	let bufnum = 0
	for l:buff in range(1, l:tot_bufs)
		let l:buf_name = fnamemodify(bufname(l:buff), ':~:.')
		if bufexists(l:buff) && getbufvar(l:buff, '&buftype') !=# 'nofile'
			let bufnum += 1
			if !getbufvar(l:buff, '&modifiable')
				let bufpath = 'w ' . l:buf_name
			elseif getbufvar(l:buff, '&modified')
				let bufpath = 'm ' . l:buf_name
			else
				let bufpath = l:buf_name
			endif
			call add(paths, bufpath)
		endif
	endfor

	let message = printf('%s :: %s/%s buffers', getcwd(), bufnum, tot_bufs)
	call insert(paths, message)
	let buf_name = fnamemodify(bufname('%'), ':~:.')
	call s:setup_navd_buf(0, paths, buf_name)
endfunction

function! navd#navdall() abort
	let cmd = 'find . \( -type d -printf "%P/\n" , -type f -printf "%P\n" \)'
" 	let cmd = 'find * -type f'
	let output = systemlist(cmd)
	call remove(output, 0)

	call insert(output, getcwd() . ' :: ' . len(output) . ' Files')
	call s:setup_navd_buf(0, output, 0)
endfunction

function! navd#navd(path, hidden) abort
	let path = s:tounix(a:path . '/')
	call s:display_paths(path, expand('%'), a:hidden, path)
endfunction
