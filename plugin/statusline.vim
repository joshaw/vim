" Created:  Wed 16 Apr 2014
" Modified: Tue 15 Mar 2016
" Author:   Josh Wainwright
" Filename: statusline.vim

if &ruler
	finish
endif

set laststatus=2 " Always show status line
set statusline=%!Status_info()
let g:c = 0

function! Status_info()
	if !exists('w:buf_stl')
		let w:buf_stl = s:status_static_info()
	endif
	let w:vissize = ''
	let mde = char2nr(mode())
	" ^V=22, V=86, v=118
	if mde == 22 || mde == 86 || mde == 118 
		let w:vissize = ' ' . (abs(line('v') - line('.')) + 1)
	endif
	if mde == 22
		let w:vissize .= '-' . (abs(getpos('v')[2] - getpos('.')[2]) + 1)
	endif
	let buf_stl = "exists('w:buf_stl') ? w:buf_stl : ''"
	let vissize = "exists('w:vissize') ? w:vissize : ''"
	return '%f%{' . buf_stl . '}%=%m%{' . vissize . '} %l/%L,%2v %P'
endfunction

function! s:bufsize(bytes)
	if a:bytes <= 0
		return ''
	endif
	let bytes = a:bytes
	let n = 0
	while bytes >= 1024
		let n += 1
		let bytes = bytes / 1024.0
	endwhile
	return printf('%.2f%s', bytes, ['B', 'KB', 'MB', 'GB'][n])
endfunction

function! s:optflags()
	let flags = ''
	let flags.=(&paste ? 'p' : '')
	let flags.=(&spell ? 's' : '')
" 	let flags.=(&wrap ? 'w' : '')
" 	let flags.=(&list ? 'l' : '')
	let flags.=(&binary ? 'b' : '')

	let flg =(&readonly || !&modifiable) ? '-' : ''
	let flg.=(&modified ? '+' : '')
	if strlen(flg) > 0
		let flags.='[' . flg . ']'
	endif
	if len(flags) > 0
		let flags= ' | ' . flags
	endif
	return flags
endfunction

function! s:status_static_info() abort
	let s:rl = len(&filetype)     ? ' | ' . &filetype : ''
	let s:rl .= len(&fileformat)   ? ' | ' . &fileformat : ''
	let s:rl .= len(&fileencoding) ? ':' . &fileencoding : ''
	let s:rl .= ' | ' . s:bufsize(line2byte(line('$') + 1))
	let s:rl .= s:optflags()
	return s:rl
endfunction

augroup ruler_info
	au!
	autocmd BufEnter     * unlet! w:buf_stl
	autocmd InsertLeave  * unlet! w:buf_stl
	autocmd BufWritePost * unlet! w:buf_stl
	autocmd TextChanged  * unlet! w:buf_stl
	autocmd OptionSet    * unlet! w:buf_stl
augroup END
