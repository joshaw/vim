" Created:  Tue 25 Aug 2015
" Modified: Mon 07 Sep 2015
" Author:   Josh Wainwright
" Filename: navd.vim

" A great deal of credit to justinmk for vim-dirvish, on which several parts of
" this are heavily based (read blatantly copied)

let s:navd_fname = '__Navd__'
let s:sep = has("win32") ? '\' : '/'
let g:navd = {}

function! s:sort_paths(p1, p2)
  let isdir1 = (a:p1[-1:] ==# s:sep) "3x faster than isdirectory().
  let isdir2 = (a:p2[-1:] ==# s:sep)
  if isdir1 && !isdir2
	return -1
  elseif !isdir1 && isdir2
	return 1
  endif
  return a:p1 ==# a:p2 ? 0 : a:p1 ># a:p2 ? 1 : -1
endfunction

" Get the list of files and folders to display in the buffer.
function! s:get_paths(path, inc_hidden)
	let l:paths = glob(a:path.'/*', 1, 1)
	if a:inc_hidden == 1
		" Include hidden files except '.' and '..'
		let l:hidden = glob(a:path.'/.[^.]*', 1, 1)
		let l:paths = extend(l:paths, l:hidden)
	endif
	return sort(map(l:paths, "fnamemodify(v:val, ':p')"), '<sid>sort_paths')
endfunction

" Create a new file or folder depending on the name given.
function! s:new_obj()
	let new_name = input('Name: ')
	redraw
	if new_name[-1:] =~# '[/\\]'
		if !isdirectory(g:navd['cur'].'/'.new_name)
			if !mkdir(g:navd['cur'].'/'.new_name)
				echoerr "Failed to create directory: ".new_name
				return
			endif
			let paths = s:get_paths(g:navd['cur'], 1)
			call s:setup_navd_buf(paths)
		else
			echo "Directory already exists: ".new_name
		endif
	else
		exe 'edit '.g:navd['cur'].new_name
	endif
	call cursor(1,1)
	call search(new_name, 'cW')
endfunction

function! s:toggle_hidden(curline)
	call s:display_paths(g:navd['cur'], !g:navd['hidden'])
	call cursor(1,1)
	call search(a:curline, 'cW')
endfunction

function! s:enter_handle()
	let cur_line = getline('.')
	if isdirectory(cur_line)
		call s:display_paths(cur_line, g:navd['hidden'])
	elseif filereadable(cur_line)
		exe 'edit' fnameescape(cur_line)
	endif
endfunction

function! s:q_handle()
	let alt = expand('#')
	if alt ==# s:navd_fname
		enew
	else
		exe 'edit' alt
	endif
endfunction

" Setup the navd buffer, write the paths and filenames to it and make it
" unwritable.
function! s:setup_navd_buf(paths)
	if &filetype !=# 'navd'
		exe 'silent! edit '.s:navd_fname
		setlocal concealcursor=nc conceallevel=3
		setlocal filetype=navd
		setlocal bufhidden=hide undolevels=-1 nobuflisted
		setlocal buftype=nofile noswapfile nowrap nolist cursorline

		" Keybindings in navd buffer
		nnoremap <silent><buffer> -    :call <SID>display_paths('<parent>', g:navd['hidden'])<cr>
		nnoremap <silent><buffer> <cr> :call <SID>enter_handle()<cr>
		nnoremap <silent><buffer> q    :call <SID>q_handle()<cr>
		nnoremap <silent><buffer> R    :call <SID>display_paths(g:navd['cur'], g:navd['hidden'])<cr>
		nnoremap <silent><buffer> gh   :call <SID>toggle_hidden(getline('.'))<cr>
		nnoremap <silent><buffer> +    :call <SID>new_obj()<cr>

		" Syntax highlighting of folders
		let sep = escape(s:sep, '/\')
		exe 'syntax match NavdPathHead ''\v.*'.sep.'\ze[^'.sep.']+'.sep.'?$'' conceal'
		exe 'syntax match NavdPathTail ''\v[^'.sep.']+'.sep.'$'''
		highlight! link NavdPathTail Directory
	endif

	setlocal modifiable
	silent %delete _
	call append(0, a:paths)
	$delete _
	silent! %s/\([/\\]\)\{2,}/\1/g
	setlocal nomodifiable
endfunction

" Call the nessessary functions, sort out where we've come from and highlight
" to right line.
function! s:display_paths(path, hidden)
	let g:navd['prev'] = has_key(g:navd, 'cur') ? g:navd['cur'] : a:path
	let g:navd['hidden'] = a:hidden

	if a:path ==# ''
		let target_path = expand('%:p:h')
		let target_fname = expand('%:t')
	elseif a:path ==# '<parent>'
		let target_path = fnamemodify(g:navd['cur'], ':p:h:h')
		let target_fname = g:navd['prev']
	else
		if isdirectory(a:path)
			let target_path = a:path
			let target_fname = g:navd['prev']
		else
			let target_path = fnamemodify(a:path, ':p:h')
			let target_fname = fnamemodify(a:path, ':p:t')
		endif
	endif
	let g:navd['cur'] = target_path

	if isdirectory(target_path)
		let hid = fnamemodify(target_fname, ':t')[0] ==# '.' ? 1 : a:hidden
		let paths = s:get_paths(target_path, hid)
		call s:setup_navd_buf(paths)
	else
		echoerr "Not a valid directory: ".target_path
		return
	endif

	call cursor(1,1)
	if !empty(target_fname)
		let sep = target_fname[0] ==# s:sep ? '' : s:sep
		if search(sep . escape(target_fname, '\\'), 'cW') <= 0
			call search(escape(target_path, '\\'), 'cW')
		endif
	elseif has_key(g:navd, 'prev') && !empty(g:navd['prev'])
		call search(escape(g:navd['prev'], '\\'), 'cW')
	endif
endfunction

function! navd#navd(path, hidden)
	call s:display_paths(a:path, a:hidden)
endfunction
