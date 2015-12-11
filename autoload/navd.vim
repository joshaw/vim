" Created:  Tue 25 Aug 2015
" Modified: Wed 09 Dec 2015
" Author:   Josh Wainwright
" Filename: navd.vim

" A great deal of credit to justinmk for vim-dirvish, on which several parts of
" this are heavily based (read blatantly copied)

let s:navd_fname = '__Navd__'
let g:navd = {}

function! s:isdir(path) abort
	return (a:path[-1:] ==# '/') "3x faster than isdirectory().
endfunction

function! s:tounix(path) abort
	return substitute(a:path, '\\', '/', 'g')
endfunction

function! s:expand(path, pat) abort
	" expand() is faster than glob(), but leaves an entry if nothing is found
	let l:paths = expand(a:path . a:pat, 1, 1)
	if len(l:paths) == 1 && l:paths[0] ==# expand(a:path) . a:pat
		return []
	endif
	return l:paths
endfunction

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

" Get the list of files and folders to display in the buffer.
function! s:get_paths(path) abort
	let path = a:path ==# '/' ? '' : a:path
	let path = path[-1:] ==# '/' ? path[0:-2] : path

	let l:paths = s:expand(path, '/*')
	if g:navd['hidden']
		" Include hidden files except '.' and '..'
		let l:paths += s:expand(path, '/.[^.]*')
	endif

	let g:navd['paths'] = []
	let cnt = 0
	for path in l:paths
		let cnt += 1
		
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
		call add(g:navd['paths'], pathdict)
	endfor

	if cnt < 100
		call sort(g:navd['paths'], '<sid>sort_paths')
	endif
endfunction

" Create a new file or folder depending on the name given.
function! s:new_obj() abort
	let l:new_name = input('Name: ')
	redraw
	if l:new_name[-1:] =~# '/'
		if isdirectory(g:navd['cur'].'/'.l:new_name)
			echo 'Directory already exists: ' . l:new_name
		else
			if mkdir(g:navd['cur'].'/'.l:new_name)
				call s:get_paths(g:navd['cur'])
				call s:setup_navd_buf(1)
			else
				echoerr 'Failed to create directory: ' . l:new_name
				return
			endif
		endif
		call search(l:new_name, 'cW')
	else
		exe 'edit '.g:navd['cur'].'/'.l:new_name
	endif
endfunction

function! s:toggle_hidden(curline) abort
	let g:navd['hidden'] = !g:navd['hidden']
	call s:display_paths(g:navd['cur'])
	call search(a:curline, 'cW')
endfunction

function! s:enter_handle() abort
	let lnum = line('.')
	if lnum == 1
		return
	endif
	let path = g:navd['paths'][lnum-2]['path']
	if filereadable(path)
		let g:status_var = ''
		exe 'edit' fnameescape(path)
		let g:navd['paths'] = []
	elseif isdirectory(path)
		call s:display_paths(path)
	else
		echo 'Cannot access' path
	endif
endfunction

function! s:q_handle() abort
	let l:alt = expand('#')
	let g:status_var = ''
	if l:alt ==# s:navd_fname
		enew
	else
		exe 'edit' l:alt
	endif
	let g:navd['paths'] = []
endfunction

function! s:current_dir() abort
	let retval = ''
	if has_key(g:navd, 'cur')
		let retval = substitute(g:navd['cur'], $HOME, '~', '')
		let g:status_var = retval
	else
		let g:status_var = ''
	endif
	if has_key(g:navd, 'message')
		let retval .= ' :: ' . g:navd['message']
	endif
	return retval
endfunction

" Setup the navd buffer, write the paths to it and make it unwritable.
function! s:setup_navd_buf(fs) abort
	if bufname('%') !=# s:navd_fname
		exe 'silent! edit ' . s:navd_fname
		setlocal filetype=navd

		setlocal concealcursor=nc conceallevel=3 bufhidden=unload undolevels=-1
		setlocal nobuflisted buftype=nowrite noswapfile nowrap nolist
		setlocal cursorline colorcolumn="" foldcolumn=0 nofoldenable
	endif

	" Keybindings in navd buffer
	if a:fs
		nnoremap <silent><buffer> -             :call <SID>display_paths('<parent>')<cr>
		nnoremap <silent><buffer> <RightMouse>  :call <SID>display_paths('<parent>')<cr>
		nnoremap <silent><buffer> R             :call <SID>display_paths(g:navd['cur'])<cr>
		nnoremap <silent><buffer> gs            :call <SID>toggle_hidden(getline('.'))<cr>
		nnoremap <silent><buffer> gh            :call <SID>display_paths($HOME)<cr>
		nnoremap <silent><buffer> +             :call <SID>new_obj()<cr>
	else
		nmapclear <buffer>
	endif
	nnoremap <silent><buffer> <cr>          :call <SID>enter_handle()<cr>
	nnoremap <silent><buffer> <2-LeftMouse> :call <SID>enter_handle()<cr>
	nnoremap <silent><buffer> q             :call <SID>q_handle()<cr>

	" Syntax highlighting of folders
	syntax clear
	syntax case match
	if a:fs
		let l:hw = len(g:navd['cur']) + 3
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

	setlocal modifiable
	silent %delete _
	call append(0, s:current_dir())
	call append(1, map(copy(g:navd['paths']), '<SID>make_line(v:val)'))
	$delete _
	setlocal nomodifiable
	call cursor(1,1)
endfunction

function! s:make_line(val)
	let acc = a:val['access']
	if a:val['type'] ==# 'D'
		let acc = toupper(acc)
	endif
	let retval = printf("%S %S", acc, a:val['path'])
	return retval
endfunction

" Call the functions, sort out where we've come from and highlight that line.
function! s:display_paths(path) abort
	let g:navd['prev'] = has_key(g:navd, 'cur') ? g:navd['cur'] : a:path

	if a:path ==# '<parent>'
		" Within the plugin to go up a level
		let target_path = fnamemodify(g:navd['cur'], ':p:h:h')
		let target_fname = g:navd['prev']

	elseif a:path ==# ''
		" Called from outside the plugin (:Navd no args)
		let target_path = expand('%:p:h')
		let target_fname = expand('%:t')

	else
		if s:isdir(a:path)
			" Called from outside the plugin (:Navd directory)
			" Or from within the plugin (enter_handle())
			let target_path = fnamemodify(a:path, ':p')
			let target_fname = g:navd['prev']

		else
			" Called from outside the plugin (:Navd file)
			let target_path = fnamemodify(a:path, ':p:h')
			let target_fname = fnamemodify(a:path, ':p:t')
		endif
	endif
	
	" Add slash to end if not present
	let target_path = s:tounix(target_path)
	let target_path .= (target_path[-1:] ==# '/') ? '' : '/'
	let g:navd['cur'] = target_path

	" Check if target name is hidden and show hidden if true
	let g:navd['hidden'] = fnamemodify(target_fname, ':t')[0] ==# '.' ? 1 : g:navd['hidden']

	call s:get_paths(target_path)
	call s:setup_navd_buf(1)

	" Find the correct line to highlight
	if search(target_fname, 'cW') <= 0
		if search(fnamemodify(target_fname, ':t'), 'cW') <= 0
			call search(target_path, 'cW')
		endif
	endif
	
	if line('.') == 1
		call cursor(2,1)
	endif
endfunction

function! g:navd#navdbuf() abort
	let l:tot_bufs = bufnr('$')
	if l:tot_bufs == 1 && bufname(1) ==# ''
		return
	endif
	let g:navd['paths'] = []
	let bufnum = 0
	for l:buff in range(1, l:tot_bufs)
		let l:buf_name = fnamemodify(bufname(l:buff), ':~:.')
		if bufexists(l:buff) && l:buf_name !~# s:navd_fname
			let bufnum += 1
			let bufdict = {'path': l:buf_name, 'type': 'b', 'access': 'f'}
			if getbufvar(l:buff, '&modified')
				let bufdict['access'] = 'm'
			endif
			if !getbufvar(l:buff, '&modifiable')
				let bufdict['access'] = 'w'
			endif
			call add(g:navd['paths'], bufdict)
		endif
	endfor

	let g:navd['message'] = bufnum . ' buffers'
	let g:navd['cur'] = getcwd()
	let l:cur_buf = bufname('%')
	call s:setup_navd_buf(0)
	call search(l:cur_buf, 'cW')
endfunction

function! g:navd#navdall() abort
	let l:cmd = 'find . \( -type d -printf "%P/\n" , -type f -printf "%P\n" \)'
	let l:cmd = 'find * -type f'
	let l:output = systemlist(l:cmd)
	call remove(l:output, 0)
	call map(l:output, '{"path": v:val, "type": "f", "access": "f"}')

	let g:navd['message'] = len(l:output) . ' Files'
	let g:navd['cur'] = getcwd()
	let g:navd['paths'] = l:output
	call s:setup_navd_buf(0)
endfunction

function! g:navd#navd(path, hidden) abort
	let g:navd['hidden'] = a:hidden
	let path = s:tounix(a:path)
	call s:display_paths(path)
endfunction
