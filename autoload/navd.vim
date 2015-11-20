" Created:  Tue 25 Aug 2015
" Modified: Fri 20 Nov 2015
" Author:   Josh Wainwright
" Filename: navd.vim

" A great deal of credit to justinmk for vim-dirvish, on which several parts of
" this are heavily based (read blatantly copied)

let s:navd_fname = '__Navd__'
let g:navd = {}

function! s:isdir(path) abort
	return (a:path[-1:] =~# '[/\\]') "3x faster than isdirectory().
endfunction

function! s:tounix(path) abort
	return substitute(a:path, '\', '/', 'g')
endfunction

function! s:expand(path, pat) abort
	" expand() is faster than glob(), but leaves an entry if nothing is found
	let l:paths = expand(a:path . a:pat, 1, 1)
	if len(l:paths) == 1 && l:paths[0] ==# expand(a:path) . a:pat
		let l:paths = []
	endif
	return l:paths
endfunction

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

function! s:init_matches() abort
	return {'noread': [], 'nowrite': [], 'mod': []}
endfunction

" Get the list of files and folders to display in the buffer.
function! s:get_paths(path, inc_hidden) abort
	let l:path = a:path ==# '/' ? '' : a:path
	let l:path = l:path[-1:] ==# '/' ? l:path[0:-2] : l:path

	if has('win32')
		let l:paths = s:expand(l:path, '/*')
		if a:inc_hidden == 1
			" Include hidden files except '.' and '..'
			let l:hidden = s:expand(l:path, '/.[^.]*')
			let l:paths = extend(l:paths, l:hidden)
		endif

	else
		let l:tpath = empty(l:path) ? '/' : l:path
		let l:tpath = fnameescape(l:tpath)
		let l:opts = (a:inc_hidden == 1 ? '-A' : '-' ) . 'q1pU --color=never '
		let l:paths = systemlist('ls ' . l:opts . l:tpath)

		let l:paths = map(l:paths, "l:path . '/' . v:val")
	endif

	let l:matches = s:init_matches()
	if len(l:paths) < 500
		call map(l:paths, "fnamemodify(v:val, ':p')")
		call sort(l:paths, '<sid>sort_paths')

		let l:counter = 1
		for l:path in l:paths
			let l:counter += 1
			if !s:isdir(l:path) && !filereadable(l:path)
				call add(l:matches['noread'], l:counter)
			elseif !filewritable(l:path)
				call add(l:matches['nowrite'], l:counter)
			endif
		endfor
	endif
	let l:paths = map(l:paths, '<sid>tounix(v:val)')
	return {'paths':l:paths, 'matches':l:matches}
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
				let l:P = s:get_paths(g:navd['cur'], 1)
				call s:setup_navd_buf(l:P['paths'], l:P['matches'], 1)
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
	if line('.') == 1
		return
	endif
	let l:cur_line = getline('.')
	if filereadable(l:cur_line)
		call clearmatches()
		let g:status_var = ''
		let l:this = bufnr('%')
		exe 'edit' fnameescape(l:cur_line)
	elseif isdirectory(l:cur_line)
		call s:display_paths(l:cur_line)
	else
		echo 'Cannot access' l:cur_line
	endif
endfunction

function! s:q_handle() abort
	let l:alt = expand('#')
	let l:this = bufnr('%')
	call clearmatches()
	let g:status_var = ''
	if l:alt ==# s:navd_fname
		enew
	else
		exe 'edit' l:alt
	endif
endfunction

function! s:current_dir() abort
	if has_key(g:navd, 'cur')
		let g:status_var = substitute(g:navd['cur'], $HOME, '~', '')
	else
		let g:status_var = ''
	endif
	return g:status_var
endfunction

" Setup the navd buffer, write the paths to it and make it unwritable.
function! s:setup_navd_buf(paths, matches, fs) abort
	if bufname('%') !=# s:navd_fname
		exe 'silent! edit ' . s:navd_fname
		setlocal filetype=navd
	endif

	setlocal concealcursor=nc conceallevel=3 bufhidden=unload undolevels=-1
	setlocal nobuflisted buftype=nowrite noswapfile nowrap nolist cursorline
	setlocal colorcolumn="" foldcolumn=0 nofoldenable

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
	if a:fs
		let l:hw = len(g:navd['cur']) + 1
" 		exe 'syntax match NavdPathHead ''\v.*'.sep.'\ze[^'.sep.']+'.sep.'?$'' conceal'
		exe 'syntax match NavdPathHead ".*\%' . l:hw . 'c" conceal'
	endif
	exe 'syntax match NavdPathTail "\v[^/]+/$"'
	syntax match NavdCurDir '\%^.*$'
	highlight! link NavdPathTail Directory
	highlight! link NavdCurDir   SpecialComment

	call clearmatches()
	for l:i in a:matches['noread']  | call matchadd('Comment', '\%'.l:i.'l') | endfor
	for l:i in a:matches['nowrite'] | call matchadd('String', '\%'.l:i.'l')  | endfor
	for l:i in a:matches['mod']     | call matchadd('Keyword', '\%'.l:i.'l') | endfor

	setlocal modifiable
	let l:save_vfile = &verbosefile
	set verbosefile=
	silent %delete _
	call append(0, s:current_dir())
	call append(1, a:paths)
	$delete _
	setlocal nomodifiable
	let &verbosefile = l:save_vfile
	call cursor(1,1)
endfunction

" Call the functions, sort out where we've come from and highlight that line.
function! s:display_paths(path) abort
	let g:navd['prev'] = has_key(g:navd, 'cur') ? g:navd['cur'] : a:path

	if a:path ==# '<parent>'
		" Within the plugin to go up a level
		let l:target_path = fnamemodify(g:navd['cur'], ':p:h:h')
		let l:target_fname = g:navd['prev']

	elseif a:path ==# ''
		" Called from outside the plugin (:Navd no args)
		let l:target_path = expand('%:p:h')
		let l:target_fname = expand('%:t')

	else
		if s:isdir(a:path)
			" Called from outside the plugin (:Navd directory)
			" Or from within the plugin (enter_handle())
			let l:target_path = a:path
			let l:target_fname = g:navd['prev']

		else
			" Called from outside the plugin (:Navd file)
			let l:target_path = fnamemodify(a:path, ':p:h')
			let l:target_fname = fnamemodify(a:path, ':p:t')
		endif
	endif
	
	" Add slash to end if not present
	let l:target_path = s:tounix(l:target_path)
	let l:target_path .= (l:target_path[-1:] ==# '/') ? '' : '/'
	let g:navd['cur'] = l:target_path

	" Check if target name is hidden and show hidden if true
	let l:hid = fnamemodify(l:target_fname, ':t')[0] ==# '.' ? 1 : g:navd['hidden']

	let l:P = s:get_paths(l:target_path, l:hid)
	call s:setup_navd_buf(l:P['paths'], l:P['matches'], 1)

	" Find the correct line to highlight
	if search(l:target_fname, 'cW') <= 0
		if search(fnamemodify(l:target_fname, ':t'), 'cW') <= 0
			call search(l:target_path, 'cW')
		endif
	endif
	
	if line('.') == 1
		call cursor(2,1)
	endif
endfunction

function! g:navd#navdbuf() abort
	let l:tot_bufs = bufnr('$')
	let l:buf_list = []
	let l:buf_count = 0
	let l:matches = s:init_matches()
	for l:buff in range(1, l:tot_bufs)
		let l:buf_name = bufname(l:buff)
		if bufexists(l:buff) && l:buf_name !~# s:navd_fname
			let l:buf_count += 1
			if getbufvar(l:buff, '&modified')
				call add(l:matches['mod'], l:buf_count)
			endif
			if !getbufvar(l:buff, '&modifiable')
				call add(l:matches['nowrite'], l:buf_count)
			endif
			call add(l:buf_list, l:buf_name)
		endif
	endfor

	let g:navd['cur'] = l:tot_bufs . ' Buffers'
	let l:cur_buf = bufname('%')
	call s:setup_navd_buf(l:buf_list, l:matches, 0)
	call search(l:cur_buf, 'cW')
endfunction

function! g:navd#navdall() abort
	let l:cmd = 'find . \( -type d -printf "%P/\n" , -type f -printf "%P\n" \)'
	let l:cmd = 'find * -type f'
	let l:matches = s:init_matches()
	let l:output = systemlist(l:cmd)
	call remove(l:output, 0)
	let g:navd['cur'] = len(l:output) . ' Files'
	call s:setup_navd_buf(l:output, l:matches, 0)
endfunction

function! g:navd#navd(path, hidden) abort
	let g:navd['hidden'] = a:hidden
	let l:path = s:tounix(a:path)
	call s:display_paths(l:path)
endfunction
