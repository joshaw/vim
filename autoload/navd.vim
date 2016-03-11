" Created:  Tue 25 Aug 2015
" Modified: Sat 27 Feb 2016
" Author:   Josh Wainwright
" Filename: navd.vim

function! navd#navd(path, hidden) abort
	let cursor = bufname('%')
	let g:altreg = @%
	if empty(cursor)
		let cursor = getcwd()
	endif
	silent! call ScratchBuf()
	let b:navd_hidden = a:hidden
	call s:display_paths(a:path, cursor, a:hidden)
	call s:keybindings(1)
endfunction

function! navd#navdall(path, indent) abort
	let path = s:norm_path(a:path)
	call ScratchBuf()
python3 << EOP
import vim
from os import walk
from os.path import join

dirs = []
path = vim.eval('path')
indent = int(vim.eval('a:indent'))
startindent = path.count('/')
for dirName, subdirList, fileList in walk(path, topdown=True):
	dirName = dirName.replace('\\', '/')
	indent = dirName.count('/') if indent else 0
	dirs.append(('    ' * (indent-startindent-1)) + dirName + '/')
	for fname in fileList:
		dirs.append(('    ' * (indent-startindent)) + dirName + '/' + fname)

vim.command('let dirs = %s' % dirs)
EOP
	call s:setup_navd_buf(dirs, "")
	call s:keybindings(0)
	if !a:indent
		setlocal conceallevel=0
	endif
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
			call add(paths, l:buf_name)
		endif
	endfor

	let message = printf('%s :: %s/%s buffers', getcwd(), bufnum, tot_bufs)
	call insert(paths, message)
	let buf_name = fnamemodify(bufname('%'), ':~:.')
	call s:display_paths(paths, buf_name)
	call s:keybindings(0)
endfunction

function! s:display_paths(path, cursor, hidden) abort
	let path = s:norm_path(a:path)
	let tail = fnamemodify(a:cursor, ':p:t')
	let hidden = tail[0] ==# '.' ? 1 : a:hidden
	if !empty(path)
		let paths = s:get_paths(path, hidden)
		call insert(paths, path)
		call s:setup_navd_buf(paths, a:cursor)
	endif
endfunction

function! s:norm_path(path) abort
	let path = a:path
	if empty(path)
		let path = getcwd()
	endif
	let path = substitute(path, '\\', '/', 'g')
	let path = substitute(path, '//', '/', 'g')
	return path
endfunction

function! s:get_paths(path, hidden) abort
	let paths = glob(a:path . '*', 1, 1)
	if a:hidden || empty(paths)
		call extend(paths, glob(a:path . '.[^.]*', 1, 1), 0)
	endif
	let dirs = []
	let files = []
	for path in paths
		if isdirectory(path)
			call add(dirs, path . '/')
		else
			call add(files, path)
		endif
	endfor
	let paths = extend(dirs, files)
	if has('win32')
		let paths = map(paths, '<SID>norm_path(v:val)')
	endif
	return paths
endfunction

function! s:setup_navd_buf(paths, cursor) abort
	setlocal modifiable
	silent! %delete _
	call append(0, a:paths)
	$delete _

	setlocal nomodifiable
	setlocal concealcursor=nc
	setlocal conceallevel=3
	setlocal undolevels=-1
	setlocal noswapfile
	setlocal nowrap
	setlocal nobuflisted
	setlocal nolist
	setlocal cursorline
	setlocal colorcolumn=""
	setlocal foldcolumn=0
	setlocal nofoldenable
	setlocal filetype=navd

	call cursor(2, 1)
	if !empty(a:cursor)
		call search(a:cursor, 'cw')
	endif
endfunction

function! s:keybindings(fs) abort
	if a:fs
		nnoremap <silent><buffer> - :call <SID>parent()<cr>
		nnoremap <silent><buffer> <space> :call <SID>preview()<cr>
		nnoremap <silent><buffer> R :call <SID>refresh()<cr>
		nnoremap <silent><buffer> s :call <SID>toggle_hidden(getline('.'))<cr>
		nnoremap <silent><buffer> gh :call navd#navd($HOME, b:navd_hidden)<cr>
		nnoremap <silent><buffer> gs :call <SID>get_obj_info()<cr>
		xnoremap <silent><buffer> gs :call <SID>get_obj_info()<cr>
		nnoremap <silent><buffer> + :call <SID>new_obj()<cr>
	else
		nmapclear <buffer>
	endif
	nnoremap <silent><buffer> <cr> :call <SID>enter()<cr>
	nnoremap <silent><buffer> q :call <SID>quit_navd()<cr>
endfunction

" Create a new file or folder depending on the name given.
function! s:new_obj() abort
	let path = getline(1)
	let new_name = input('Name: ')
	let new_obj = path . new_name
	if new_name[-1:-1] ==# '/'
		if isdirectory(new_obj)
			echo 'Directory already exists: ' . new_name
			call search(new_obj, 'cw')
		else
			if mkdir(new_obj)
				call s:refresh()
				call search(new_name, 'cw')
			else
				echoerr 'Failed to create directory: ' . new_name
				return
			endif
		endif
	else
		exe 'edit ' . new_obj
	endif
endfunction

function! s:toggle_hidden(curline) abort
	let b:navd_hidden = !b:navd_hidden
	call s:refresh()
	echo (b:navd_hidden == 1 ? 'S' : 'Not s') . 'howing hidden files'
endfunction

function! s:enter() abort
	let path = substitute(getline('.'), '^\s*', '', '')
	if filereadable(path)
		exe 'edit' fnameescape(path)
		let @# = g:altreg
		unlet g:altreg
	elseif isdirectory(path)
		call s:display_paths(path, '', b:navd_hidden)
	else
		echo 'Cannot access' path
	endif
endfunction

function! s:parent() abort
	let path = fnamemodify(getline(1), ':p:h:h') . '/'
	let cursor = getline(1)
	call s:display_paths(path, cursor, b:navd_hidden)
endfunction

function! s:refresh() abort
	let path = getline(1)
	let cursor = getline('.')
	call s:display_paths(path, cursor, b:navd_hidden)
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
		let @# = g:altreg
	endif
	silent! unlet g:altreg
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
