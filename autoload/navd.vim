" Created:  Tue 25 Aug 2015
" Modified: Mon 02 Nov 2015
" Author:   Josh Wainwright
" Filename: navd.vim

" A great deal of credit to justinmk for vim-dirvish, on which several parts of
" this are heavily based (read blatantly copied)

let s:navd_fname = '__Navd__'
let s:sep = has("win32") ? '\' : '/'
let g:navd = {}

function! s:isdir(path)
	return (a:path[-1:] ==# s:sep) "3x faster than isdirectory().
endfunction

function! s:sort_paths(p1, p2)
  let isdir1 = s:isdir(a:p1)
  let isdir2 = s:isdir(a:p2)
  if isdir1 && !isdir2
	return -1
  elseif !isdir1 && isdir2
	return 1
  endif
  return a:p1 ==# a:p2 ? 0 : a:p1 ># a:p2 ? 1 : -1
endfunction

function! s:init_matches()
	return {'noread': [], 'nowrite': [], 'mod': []}
endfunction

" Get the list of files and folders to display in the buffer.
function! s:get_paths(path, inc_hidden)
	let path = a:path ==# '/' ? '' : a:path
	let l:paths = glob(path.'/*', 1, 1)
	if a:inc_hidden == 1
		" Include hidden files except '.' and '..'
		let l:hidden = glob(path.'/.[^.]*', 1, 1)
		let l:paths = extend(l:paths, l:hidden)
	endif
	call map(l:paths, "fnamemodify(v:val, ':p')")
	call sort(l:paths, '<sid>sort_paths')
	let counter = 0
	let matches = s:init_matches()
	for path in l:paths
		let counter += 1
		if !s:isdir(path) && !filereadable(path)
			call add(matches['noread'], counter)
		elseif !filewritable(path)
			call add(matches['nowrite'], counter)
		endif
	endfor
	return {'paths':l:paths, 'matches':matches}
endfunction

" Create a new file or folder depending on the name given.
function! s:new_obj()
	let new_name = input('Name: ')
	redraw
	if new_name[-1:] =~# '[/\\]'
		if isdirectory(g:navd['cur'].'/'.new_name)
			echo "Directory already exists: ".new_name
		else
			if mkdir(g:navd['cur'].'/'.new_name)
				let P = s:get_paths(g:navd['cur'], 1)
				call s:setup_navd_buf(P['paths'], P['matches'])
			else
				echoerr "Failed to create directory: ".new_name
				return
			endif
		endif
		call search(new_name, 'cW')
	else
		exe 'edit '.g:navd['cur'].'/'.new_name
	endif
endfunction

function! s:toggle_hidden(curline)
	let g:navd['hidden'] = !g:navd['hidden']
	call s:display_paths(g:navd['cur'])
	call search(a:curline, 'cW')
endfunction

function! s:enter_handle()
	if line('.') == 1
		return
	endif
	let cur_line = getline('.')
	if isdirectory(cur_line)
		call s:display_paths(cur_line)
	elseif filereadable(cur_line)
		call clearmatches()
		let g:status_var = ''
		let this = bufnr('%')
		exe 'edit' fnameescape(cur_line)
		exe 'bwipeout' this
	else
		echoerr 'Cannot access' cur_line
	endif
endfunction

function! s:q_handle()
	let alt = expand('#')
	let this = bufnr('%')
	call clearmatches()
	if alt ==# s:navd_fname
		enew
	else
		exe 'edit' alt
	endif
	exe 'bwipeout' this
endfunction

function! s:current_dir()
	if has_key(g:navd, 'cur')
		let g:status_var = substitute(g:navd['cur'], $HOME, '~/', '')
	else
		let g:status_var = ''
	endif
	return g:status_var
endfunction

" Setup the navd buffer, write the paths to it and make it unwritable.
function! s:setup_navd_buf(paths, matches)
	if &filetype !=# 'navd'
		exe 'silent! edit ' . s:navd_fname
		setlocal filetype=navd
		setlocal concealcursor=nc conceallevel=3 bufhidden=hide undolevels=-1
		setlocal nobuflisted buftype=nofile noswapfile nowrap nolist cursorline
		setlocal colorcolumn="" foldcolumn=0 nofoldenable

		" Keybindings in navd buffer
		nnoremap <silent><buffer> -             :call <SID>display_paths('<parent>')<cr>
		nnoremap <silent><buffer> <RightMouse>  :call <SID>display_paths('<parent>')<cr>
		nnoremap <silent><buffer> <cr>          :call <SID>enter_handle()<cr>
		nnoremap <silent><buffer> <2-LeftMouse> :call <SID>enter_handle()<cr>
		nnoremap <silent><buffer> q             :call <SID>q_handle()<cr>
		nnoremap <silent><buffer> R             :call <SID>display_paths(g:navd['cur'])<cr>
		nnoremap <silent><buffer> gs            :call <SID>toggle_hidden(getline('.'))<cr>
		nnoremap <silent><buffer> gh            :call <SID>display_paths('$HOME/')<cr>
		nnoremap <silent><buffer> +             :call <SID>new_obj()<cr>

		" Syntax highlighting of folders
		let sep = escape(s:sep, '/\')
		exe 'syntax match NavdPathHead ''\v.*'.sep.'\ze[^'.sep.']+'.sep.'?$'' conceal'
		exe 'syntax match NavdPathTail ''\v[^'.sep.']+'.sep.'$'''
		syntax match NavdCurDir '\%^.*$'
		highlight! link NavdPathTail Directory
		highlight! link NavdCurDir   Comment
	endif
	call clearmatches()
	for i in a:matches['noread']  | call matchadd('Comment', '\%'.i.'l') | endfor
	for i in a:matches['nowrite'] | call matchadd('String', '\%'.i.'l')  | endfor
	for i in a:matches['mod']     | call matchadd('Keyword', '\%'.i.'l') | endfor

	setlocal modifiable
	let save_vfile = &verbosefile
	set verbosefile=
	silent %delete _
	call append(0, s:current_dir())
	call append(1, a:paths)
	$delete _
	keeppatterns silent! %s/\([/\\]\)\{2,}/\1/ge
	setlocal nomodifiable
	let &verbosefile = save_vfile
	call cursor(1,1)
endfunction

" Call the functions, sort out where we've come from and highlight that line.
function! s:display_paths(path)
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
			let target_path = a:path
			let target_fname = g:navd['prev']

		else
			" Called from outside the plugin (:Navd file)
			let target_path = fnamemodify(a:path, ':p:h')
			let target_fname = fnamemodify(a:path, ':p:t')
		endif
	endif
	let g:navd['cur'] = target_path

	let hid = fnamemodify(target_fname, ':t')[0] ==# '.' ? 1 : g:navd['hidden']
	let P = s:get_paths(target_path, hid)
	call s:setup_navd_buf(P['paths'], P['matches'])

	" Find the correct line to highlight
	let sep = target_fname[0] ==# s:sep ? '' : s:sep
	if search(sep . escape(target_fname, '\\'), 'cW') <= 0
		call search(escape(target_path, '\\'), 'cW')
	endif
	
	if line('.') == 1
		normal j
	endif
endfunction

function! navd#navdbuf()
	let tot_bufs = bufnr('$')
	let buf_list = []
	let buf_count = 0
	let matches = s:init_matches()
	for buff in range(1, tot_bufs)
		let buf_name = bufname(buff)
		if bufexists(buff) && buf_name !~# s:navd_fname
			let buf_count += 1
			if getbufvar(buff, '&modified')
				call add(matches['mod'], buf_count)
			endif
			if !getbufvar(buff, '&modifiable')
				call add(matches['nowrite'], buf_count)
			endif
			call add(buf_list, buf_name)
		endif
	endfor

	let cur_buf = bufname('%')
	call s:setup_navd_buf(buf_list, matches)
	call search(cur_buf, 'cW')
endfunction

function! navd#navdall()
	let cmd = 'find . \( -type d -printf "%P/\n" , -type f -printf "%P\n" \)'
	let cmd = 'ag --nogroup --hidden -g .'
	let matches = s:init_matches()
	let output = systemlist(cmd)
	call remove(output, 0)
	call s:setup_navd_buf(output, matches)
endfunction

function! navd#navd(path, hidden)
	let g:navd['hidden'] = a:hidden
	call s:display_paths(a:path)
endfunction
