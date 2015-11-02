" Created:  Wed 16 Apr 2014
" Modified: Mon 02 Nov 2015
" Author:   Josh Wainwright
" Filename: statusline.vim

set ls=2 " Always show status line

function! s:statuslineconvert(n, orig)
	let p = has('gui_running') ? 'gui' : 'cterm'
	exec 'hi User' . a:n p . 'fg=' . synIDattr(synIDtrans(hlID(a:orig)), 'fg')
				\ p . 'bg=' . s:ccbg
endfunction

" Set up the colors for the status bar
function! statusline#colour()
	" Basic color presets
	let s:ccbg = synIDattr(synIDtrans(hlID('ColorColumn')), 'bg')
	call s:statuslineconvert(5, 'Comment')
	call s:statuslineconvert(7, 'Operator')
	call s:statuslineconvert(8, 'Identifier')
	call s:statuslineconvert(9, 'Normal')
endfunc

function! statusline#filepath()
	if expand('%') == ''
		return ''
	else
		let l:home = escape($HOME, '\')
		let l:curfile = expand('%:p:h')
		let l:curfile = substitute(l:curfile, l:home, '~', '')
		let l:curfile = substitute(l:curfile, '\\', '/', 'g')
		return l:curfile . '/'
	endif
endfunction

function! statusline#optflags()
	let flags = ''
	let flags.=(&paste != 0 ? 'p' : '')
	let flags.=(&spell != 0 ? 's' : '')
" 	let flags.=(&wrap != 0 ? 'w' : '')
	let flags.=(&bin != 0 ? 'b' : '')
	let flags.=(&ro != 0 ? ' ro' : '')
	if flags ==# ' ro'
		let flags = 'ro'
	endif
	if len(flags) > 0
		let flags= '['.flags.']'
	endif
	return flags
endfunction

let s:stl= ""
let s:stl.="%5*%<%{statusline#filepath()}"       " file path
let s:stl.="%9*%t "                              " file name
let s:stl.="%7*%([%M]%) "                        " modified flag

let s:stl.="%="                                  " right-align

let s:stl.="%7*%{(exists('g:status_var') ? g:status_var : '')} "
let s:stl.="%9*%{statusline#optflags()} "        " option flags
let s:stl.="%8*%{&filetype} "                    " file type
let s:stl.="%9*%{(&ff=='unix'?'u':&ff)}"         " file format
let s:stl.="%(%{(&fenc=='utf-8'?'8':&fenc)} |%)" " file encoding
let s:stl.="%3.c:"                               " column number
let s:stl.="%7*%3.l%8*/%-2.L\ "                  " line number / total lines
let s:stl.="%3.p%% "                             " percentage done

augroup statusline
	" whenever the color scheme changes re-apply the colors
	au ColorScheme,VimEnter * call statusline#colour()
	au WinEnter,BufEnter,Filetype * call setwinvar(0, "&statusline", s:stl)
	au WinLeave *  exec "hi StatusLineNC guifg=#BBBBBB guibg=#111111" |
				\ call setwinvar(0, "&statusline", "")
augroup END

set showtabline=2
set tabline=%!MyTabLine()
function! MyTabLine()
	let s = ''
	for i in range(1, bufnr('$'))
		" select the highlighting
		if bufnr('%') == i
			let s .= '%#TabLineSel#'
		elseif buflisted(i) > 0
			let s .= '%#TabLine#'
		else
			continue
		endif

		" the label is made by MyTabLabel()
		let s .= ' %{MyTabLabel(' . i . ')} '
	endfor

	" after the last tab fill with TabLineFill and reset tab page nr
	let s .= '%#TabLineFill#'
	return s
endfunction

function! MyTabLabel(n)
	let name = fnamemodify(bufname(a:n), ':p:t')
	let mod = getbufvar(a:n, '&modified') == 1 ? '+' : ''
	return a:n . mod . ' ' . name
endfunction
