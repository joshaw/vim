" Created:  Wed 16 Apr 2014
" Modified: Thu 28 Jan 2016
" Author:   Josh Wainwright
" Filename: statusline.vim

if &ruler
	finish
endif

set laststatus=2 " Always show status line

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
	if expand('%') ==# ''
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
	let flags.=(&binary != 0 ? 'b' : '')
	let flags.=(&readonly != 0 ? ' ro' : '')
	if flags ==# ' ro'
		let flags = 'ro'
	endif
	if len(flags) > 0
		let flags= '['.flags.']'
	endif
	return flags
endfunction

let s:stl= ''
let s:stl.='%5*%<%{statusline#filepath()}'       " file path
let s:stl.='%9*%t '                              " file name
let s:stl.='%7*%([%M]%) '                        " modified flag

let s:stl.='%='                                  " right-align

let s:stl.='%7*%{(exists("g:status_var") ? g:status_var : "")} '
let s:stl.='%9*%{statusline#optflags()} '        " option flags
let s:stl.='%8*%{&filetype} '                    " file type
let s:stl.='%9*%{(&ff=="unix"?"u":&ff)}'         " file format
let s:stl.='%(%{(&fenc=="utf-8"?"8":&fenc)} |%)' " file encoding
let s:stl.='%3.c:'                               " column number
let s:stl.='%7*%3.l%8*/%-2.L '                   " line number / total lines
let s:stl.='%3.p%% '                             " percentage done

augroup statusline
	" whenever the color scheme changes re-apply the colors
	au ColorScheme,VimEnter * call statusline#colour()
	au WinEnter,BufEnter,Filetype * call setwinvar(0, "&statusline", s:stl)
	au WinLeave *  exec "hi StatusLineNC guifg=#BBBBBB guibg=#111111" |
				\ call setwinvar(0, "&statusline", "")
augroup END

let s:prev_currentbuf = winbufnr(0)
function! BufLineRender()
	" help buffers are always unlisted, but quickfix buffers are not
	let bufnums = filter(range(1,bufnr('$')),'buflisted(v:val) && "quickfix" !=? getbufvar(v:val, "&buftype")')

	" pick up data on all the buffers
	let tabs = []
	let tabs_by_tail = {}
	let currentbuf = winbufnr(0)
	for bufnum in bufnums
		let tab = { 'num': bufnum }
		let tab.hilite = (currentbuf == bufnum) ? 'Sel' : ''
		let bufpath = bufname(bufnum)

		if strlen(bufpath)
			let bufpath = substitute(fnamemodify(bufpath, ':p:~:.'), '^$', '.', '')
			let tab.head = fnamemodify(bufpath, ':h')
			let tab.tail = fnamemodify(bufpath, ':t')
			let tab.tail = len(tab.tail) == 0 ? './' : tab.tail
			let pre = bufnum . (getbufvar(bufnum, '&mod') ? '+ ' : ' ')

			let tab.fmt = ' ' . pre . '%s' . ' '
			let tabs_by_tail[tab.tail] = get(tabs_by_tail, tab.tail, []) + [tab]

		" scratch buffer
		elseif -1 < index(['nofile','acwrite'], getbufvar(bufnum, '&buftype'))
			let tab.label = ' !' . bufnum . ' '

		" unnamed file
		else
			let tab.label = ' ' . bufnum . (getbufvar(bufnum, '&mod') ? ' +' : ' ')
		endif

		let tabs += [tab]
	endfor

	" disambiguate same-basename files by adding trailing path segments
	while 1
		let groups = filter(values(tabs_by_tail),'len(v:val) > 1')
		if !len(groups)
			break
		endif

		for group in groups
			call remove(tabs_by_tail, group[0].tail)
			for tab in group
				if strlen(tab.head) && tab.head !=# '.'
					let tab.tail = fnamemodify(tab.head, ':t') . '/' . tab.tail
					let tab.head = fnamemodify(tab.head, ':h')
				endif
				let tabs_by_tail[tab.tail] = get(tabs_by_tail, tab.tail, []) + [tab]
			endfor
		endfor
	endwhile

	" now keep the current buffer center-screen as much as possible:

	" 1. setup
	let lft = {'lasttab':  0, 'cut':  '.', 'indicator': '<', 'width': 0, 'half': &columns / 2}
	let rgt = {'lasttab': -1, 'cut': '.$', 'indicator': '>', 'width': 0, 'half': &columns - lft.half}

	" 2. if current buffer not a user buffer, remember the previous one
	"    (to keep the tabline from jumping around e.g. when browsing help)
	if -1 == index(bufnums, currentbuf)
		let currentbuf = s:prev_currentbuf
	else
		let s:prev_currentbuf = currentbuf
	endif

	" 3. sum the string lengths for the left and right halves
	let currentside = lft
	for tab in tabs

		if has_key(tab, 'fmt')
			let tab.label = printf(tab.fmt, tab.tail)
		endif

		let tab.width = strwidth(tab.label)
		if currentbuf == tab.num
			let halfwidth = tab.width / 2
			let lft.width += halfwidth
			let rgt.width += tab.width - halfwidth
			let currentside = rgt
			continue
		endif
		let currentside.width += tab.width
	endfor

	" no current window seen?
	if 0 == rgt.width
		" then blame any overflow on the right side, to protect the left
		let [lft.width, rgt.width] = [0, lft.width]
	endif

	" 3. toss away tabs and pieces until all fits:
	if ( lft.width + rgt.width ) > &columns
		for [side,otherside] in [ [lft,rgt], [rgt,lft] ]
			if side.width > side.half
				let remainder = otherside.width < otherside.half ? &columns - otherside.width : side.half
				let delta = side.width - remainder
				" toss entire tabs to close the distance
				while delta >= tabs[side.lasttab].width
					let gain = tabs[side.lasttab].width
					let delta -= gain
					call remove(tabs, side.lasttab, side.lasttab)
				endwhile
				" then snip at the last one to make it fit
				let endtab = tabs[side.lasttab]
				while delta > ( endtab.width - strwidth(endtab.label) )
					let endtab.label = substitute(endtab.label, side.cut, '', '')
				endwhile
				let endtab.label = substitute(endtab.label, side.cut, side.indicator, '')
			endif
		endfor
	endif

	return '%T' . join(map(tabs,'printf("%%#Tabline%s#%s",v:val.hilite,v:val.label)'),'') . '%#TabLineFill#'
endfunction

function! BufLineUpdate()
	set tabline=
	if tabpagenr('$') > 1
		set guioptions+=e showtabline=2
		return
	endif
	if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) > 1
		set guioptions-=e
		set showtabline=2
		set tabline=%!BufLineRender()
	endif
endfunction

augroup buftabline
	autocmd BufAdd,BufDelete,TabEnter,VimEnter * call BufLineUpdate()
augroup END
