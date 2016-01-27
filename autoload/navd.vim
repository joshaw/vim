" Created:  Tue 25 Aug 2015
" Modified: Wed 27 Jan 2016
" Author:   Josh Wainwright
" Filename: navd.vim

" A great deal of credit to justinmk for vim-dirvish, on which several parts of
" this are heavily based (read blatantly copied)

let g:navd = {}

" Return 1 if the path ends in a slash, indicating it is a directory
function! s:isdir(path) abort
	return (a:path[-1:] ==# '/') "3x faster than isdirectory().
endfunction

" Return the path converted to use unix style path separators
function! s:tounix(path) abort
	let path = substitute(a:path, '\\', '/', 'g')
	return substitute(path, '//', '/', 'g')
endfunction

" Return a list of paths matching the given pattern in the given directory
function! s:expand(path, pat) abort
	" expand() is faster than glob(), but leaves an entry if nothing is found
	let l:paths = expand(a:path . a:pat, 1, 1)
	if len(l:paths) == 1 && l:paths[0] ==# expand(a:path) . a:pat
		return []
	endif
	return l:paths
endfunction

function! s:curdir() abort
	return g:navd['cur']
endfunction

" Return the sort index for the two paths
function! s:sort_paths(p1, p2) abort
	let p1 = a:p1['path']
	let p2 = a:p2['path']
	let l:isdir1 = s:isdir(p1)
	let l:isdir2 = s:isdir(p2)
	if l:isdir1 && !l:isdir2
		return -1
	elseif !l:isdir1 && l:isdir2
		return 1
	endif
	return p1 ==# p2 ? 0 : p1 ># p2 ? 1 : -1
endfunction

" Return the list of files and folders to display in the buffer.
function! s:get_paths(path, hidden) abort
	let path = a:path ==# '/' ? '' : a:path
	let path = path[-1:] ==# '/' ? path[0:-2] : path

	let paths = s:expand(path, '/*')
	if a:hidden
		" Include hidden files except '.' and '..'
		let paths += s:expand(path, '/.[^.]*')
	endif

	let cnt = 0
	for path in paths
		
		let path = s:tounix(fnamemodify(path, ':p'))
		let pathdict = {'path': path, 'type': 'f', 'access': 'f'}

		if s:isdir(path)
			let pathdict['type'] = 'D'
			let pathdict['access'] = 'D'
		elseif !filereadable(path)
			let pathdict['access'] = 'r'
		endif

		if !filewritable(path)
			let pathdict['access'] = 'w'
		endif
		let paths[cnt] = pathdict
		let cnt += 1
	endfor

	call sort(paths, '<sid>sort_paths')
	return paths
endfunction

" Create a new file or folder depending on the name given.
function! s:new_obj(dir) abort
	let l:new_name = input('Name: ')
	let new_obj = s:tounix(a:dir . '/' . l:new_name)
	redraw
	if s:isdir(l:new_name)
		if isdirectory(new_obj)
			echo 'Directory already exists: ' . l:new_name
			call search(new_obj, 'cw')
		else
			if mkdir(new_obj)
				call s:display_paths(a:dir, new_obj)
			else
				echoerr 'Failed to create directory: ' . l:new_name
				return
			endif
		endif
	else
		exe 'edit ' . new_obj
	endif
endfunction

function! s:get_obj_info() abort
	let lnum = line('.')
	let path = g:navd['paths'][lnum-2]['path']
	if isdirectory(path)
		let path = shellescape(path)
		let sizestr = systemlist('du -sh ' . path)[0]
	else
		let path = shellescape(path)
		let sizestr = systemlist('ls -Gghmn --time-style=+"" ' . path)[0]
	endif
	echo sizestr
endfunction

function! s:toggle_hidden(curline) abort
	let g:navd['hidden'] = !g:navd['hidden']
	echo (g:navd['hidden'] == 1 ? 'S' : 'Not s') . 'howing hidden files'
	call s:display_paths(s:curdir(), a:curline)
endfunction

function! s:enter() abort
	let lnum = line('.')
	if lnum == 1
		return
	endif
	let path = g:navd['paths'][lnum-2]['path']
	if filereadable(path)
		exe 'edit' fnameescape(path)
		let g:navd['paths'] = []
	elseif isdirectory(path)
		call s:display_paths(path, 0)
	else
		echo 'Cannot access' path
	endif
endfunction

" Quite navd and return to previously edited file
function! s:quit_navd() abort
	let l:alt = bufnr('#')
	if l:alt < 0 || bufnr('$') == 1
		enew
	elseif l:alt == bufnr('%')
		buffer 1
	else
		exe 'buffer' l:alt
	endif
	let g:navd['paths'] = []
endfunction

" Pipe file through less or dir through tree to see preview
function! s:preview() abort
	let lnum = line('.')
	if lnum == 1
		return
	endif
	let path = g:navd['paths'][lnum-2]['path']
	if filereadable(path)
		silent exe "!less " . shellescape(path)
		redraw!
	elseif isdirectory(path)
		silent exe "!tree " . shellescape(path) . ' | less -R'
		redraw!
	endif
endfunction

" Setup the navd buffer, write the paths to it and make it unwritable.
function! s:setup_navd_buf(fs, paths, cursor) abort
	call ScratchBufHere()

	setlocal filetype=navd
	setlocal concealcursor=nc conceallevel=3 undolevels=-1
	setlocal nobuflisted buftype=nofile noswapfile nowrap nolist
	setlocal cursorline colorcolumn="" foldcolumn=0 nofoldenable

	" Keybindings in navd buffer
	if a:fs
		nnoremap <silent><buffer> -             :call <SID>display_paths('<parent>', getline(1))<cr>
		nnoremap <silent><buffer> <RightMouse>  :call <SID>display_paths('<parent>', getline(1))<cr>
		nnoremap <silent><buffer> <space>       :call <SID>preview()<cr>
		nnoremap <silent><buffer> R             :call <SID>display_paths(s:curdir(), getline('.'))<cr>
		nnoremap <silent><buffer> s             :call <SID>toggle_hidden(getline('.'))<cr>
		nnoremap <silent><buffer> gh            :call <SID>display_paths($HOME, 0)<cr>
		nnoremap <silent><buffer> gs            :call <SID>get_obj_info()<cr>
		xnoremap <silent><buffer> gs            :call <SID>get_obj_info()<cr>
		nnoremap <silent><buffer> +             :call <SID>new_obj(s:curdir())<cr>
	else
		nmapclear <buffer>
	endif
	nnoremap <silent><buffer> <cr>          :call <SID>enter()<cr>
	nnoremap <silent><buffer> <2-LeftMouse> :call <SID>enter()<cr>
	nnoremap <silent><buffer> q             :call <SID>quit_navd()<cr>

	" Syntax highlighting of folders
	syntax clear
	syntax case match
	if a:fs
		let l:hw = len(s:curdir()) + 3
" 		exe 'syn match NavdHead ''\v.*/\ze[^/]+/?$'' conceal'
		exe 'syn match NavdHead ".*\%' . l:hw . 'c" conceal'
	else
		syn match NavdHead '^\w ' conceal
	endif
	syn match NavdPath    '^D .*$' contains=NavdHead
	syn match NavdNoRead  '^R .*$' contains=NavdHead
	syn match NavdNoWrite '^W .*$' contains=NavdHead
	syn match NavdNoRead  '^r .*$' contains=NavdHead
	syn match NavdNoWrite '^w .*$' contains=NavdHead
	syn match NavdMod     '^m .*$' contains=NavdHead
	syn match NavdCurDir  '\%^.*$'
	hi! link NavdTail    Directory
	hi! link NavdPath    Directory
	hi! link NavdNoRead  Comment
	hi! link NavdNoWrite String
	hi! link NavdMod     Keyword
	hi! link NavdCurDir  SpecialComment

	let g:navd['paths'] = a:paths
	setlocal modifiable
	silent %delete _
	call append(0, substitute(g:navd['message'], $HOME, '~', ''))
	call append(1, map(copy(a:paths), '<SID>make_line(v:val)'))
	$delete _
	setlocal nomodifiable

	" Find the correct line to highlight
	call cursor(2, 1)
	if !empty(a:cursor)
		call search('\V' . a:cursor, 'cw')
	endif
endfunction

function! s:make_line(val)
	let acc = a:val['access']
	if a:val['type'] ==# 'D'
		let acc = toupper(acc)
	endif
	return printf("%S %S", acc, a:val['path'])
endfunction

" Call the functions, sort out where we've come from and highlight that line.
function! s:display_paths(path, cursor) abort
	if a:path ==# '<parent>'
		" Within the plugin to go up a level
		let target_path = fnamemodify(s:curdir(), ':p:h:h')

	elseif empty(a:path)
		" Called from outside the plugin (:Navd no args)
		let target_path = expand('%:p:h')

	else
		if isdirectory(a:path)
			" Called from outside the plugin (:Navd directory)
			" Or from within the plugin (enter())
			let target_path = fnamemodify(a:path, ':p')

		else
			" Called from outside the plugin (:Navd file)
			let target_path = fnamemodify(a:path, ':p:h')
		endif
	endif
	
	" Add slash to end if not present
	let target_path = s:tounix(target_path)
	let target_path .= (target_path[-1:] ==# '/') ? '' : '/'
	let g:navd['cur'] = target_path
	let g:navd['message'] = target_path
	let cursor = s:tounix(a:cursor)

	" Check if target name is hidden and show hidden if true
	let g:navd['hidden'] = fnamemodify(cursor, ':t')[0] ==# '.' ? 1 : g:navd['hidden']

	call s:setup_navd_buf(1, s:get_paths(target_path, g:navd['hidden']), cursor)
endfunction

function! g:navd#navdbufs() abort
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
			let bufdict = {'path': l:buf_name, 'type': 'b', 'access': 'f'}
			if getbufvar(l:buff, '&modified')
				let bufdict['access'] = 'm'
			endif
			if !getbufvar(l:buff, '&modifiable')
				let bufdict['access'] = 'w'
			endif
			call add(paths, bufdict)
		endif
	endfor

	let g:navd['message'] = printf('%s :: %s/%s buffers', getcwd(), bufnum, tot_bufs)
	call s:setup_navd_buf(0, paths, bufname('%'))
endfunction

function! g:navd#navdall() abort
	let cmd = 'find . \( -type d -printf "%P/\n" , -type f -printf "%P\n" \)'
	let cmd = 'find * -type f'
	let output = systemlist(cmd)
	call remove(output, 0)
	call map(output, '{"path": v:val, "type": "f", "access": "f"}')

	let g:navd['message'] = getcwd() . ' :: ' . len(output) . ' Files'
	call s:setup_navd_buf(0, output, 0)
endfunction

function! g:navd#navd(path, hidden) abort
	let g:navd['hidden'] = a:hidden
	let path = s:tounix(a:path)
	call s:display_paths(path, expand('%'))
endfunction
