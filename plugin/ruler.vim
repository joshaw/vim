" Created:  Thu 28 Jan 2016
" Modified: Mon 08 Feb 2016
" Author:   Josh Wainwright
" Filename: ruler.vim

if ! &ruler
	finish
endif

function! s:setupRuler()
	set laststatus=0
	set statusline=

	let s:rl = '%' . (winwidth(0)/2) . '(%=%t%m %l/%L,%2v %3p%%%)'
	let &rulerformat=s:rl
endfunction
call s:setupRuler()
autocmd VimResized,BufWrite,BufRead * call <SID>setupRuler()

function! Ruler_temp_info()
	let curlnr = line('.')
	let totlnr = line('$')
	let perc = string(float2nr(eval(curlnr)*1.0/eval(totlnr) * 100))
	let mod = &modified ? '[+]' : ''
	let right = printf("%20s", mod . ' ' . curlnr . '/' . totlnr . ' ' . perc . '%')
	echo s:rl . right
endfunction

function! Ruler_static_info() abort
	if !exists('g:rulerfmt_save')
		let g:rulerfmt_save = &rulerformat
	endif
	let &rulerformat = '%1(%)'
	let s:rl = fnamemodify(bufname('%'), ':~:.')
	let s:rl .= '  [' . &filetype . ']'
	let s:rl .= '  ' . &fileformat . ':' . &fileencoding
	silent let s:rl .= '  ' . eunuch#FileSize(0)
	let s:rl .= repeat(' ', &columns - strwidth(s:rl) - 23)
endfunction

function! Ruler_setup()
	redraw
	set rulerformat=
	call Ruler_static_info()
	call Ruler_temp_info()
	augroup ruler_info
		au!
		autocmd BufWritePost * call Ruler_setup()
		autocmd InsertLeave  * call Ruler_setup()
		autocmd BufEnter     * call Ruler_setup()
		autocmd CursorMoved  * call Ruler_temp_info()
	augroup END
endfunction
