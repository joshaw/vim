" Created:  Mon 13 Jul 2015
" Modified: Thu 10 Dec 2015
" Author:   Josh Wainwright
" Filename: surroundings.vim

" abc def ghi

function! surroundings#surroundings(visual)
	if a:visual > 0
		echon 'Char: '
		let c = nr2char(getchar())
		let start = c
	else
		echon 'In/Out: '
		let c = nr2char(getchar())
		if c =~# '^[ia]$'
			let obj = c
			redraw
			echon 'Char: '
			let mov = nr2char(getchar())
		else
			let obj = ''
			let mov = c
		endif
		redraw
		echon 'Start: '
		let start = nr2char(getchar())
	endif

	let matched = {'(': ')', '[': ']', '{': '}', '<': '>'}
	if has_key(matched, start)
		let end = matched[start]
	else
		let end = start
	endif

	let treg = @t
	let virtualeditsave = &virtualedit
	set virtualedit=all

	if a:visual == 2
		exe 's/^\(\s*\)\(.*\)$/\1'.start.'\2'.end.'/'
	else
		if a:visual == 1
			exe "normal! gv\"td"
		else
			exe "normal! v".obj.mov
			exe "normal! \"td"
		endif
		exe "normal! i".start."\"tpa".end.""
	endif
	let @t = treg

	let &virtualedit = virtualeditsave
endfunction
