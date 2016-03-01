" Created:  Tue 27 Oct 2015
" Modified: Thu 28 Jan 2016
" Author:   Josh Wainwright
" Filename: align.vim

function! g:align#align(char, delspace, alignright) range abort
	" Set default align character if none is given
	let char = empty(a:char) ? '|' : a:char
	let char = substitute(char, '\\ ', ' ', 'g')
	let char = substitute(char, '\\t', '	', 'g')
	let linesplit = []
	let mem = {}

	" Split all lines in range using char
	for l:i in range(a:firstline, a:lastline)
		let line = getline(l:i)
		let cols = split(line, '\s*'.char.'\s*', 1)
		let linesplit = add(linesplit, cols)

		" For each column, check if it is the longest
		for l:j in range(0, len(cols)-1)
			let len = strwidth(cols[l:j])
			if !has_key(mem, l:j) || len > mem[l:j]
				let mem[l:j] = len
			endif
		endfor
	endfor
	unlet line

	" Set separator char depending on options set
	let joinchar = a:delspace ? char : ' ' . char . ' '
	let newlines = []
	let lcount = 0
	for line in linesplit
		let newline = ''

		" Join line segments using char with padding
		for col in range(0, len(line)-2)
			let spaces = repeat(' ' , mem[col] - len(line[col]))
			if a:alignright
				let newline = newline . spaces . line[col] . joinchar
			else
				let newline = newline . line[col] . spaces . joinchar
			endif
		endfor

		" Remove trailing spaces added
		if !a:delspace && len(line[-1]) == 0
			let newline = newline[0:-2]
		else
			let newline = newline . line[-1]
		endif

		" Replace lines with aligned lines
		call setline(a:firstline + lcount, newline)
		let lcount += 1
	endfor
	redraw
	echo lcount . ' lines aligned.'
endfunction

function! align#alignmap(type, ...) abort
	let [lnum1, lnum2] = [line("'["), line("']")]
	exe lnum1 . ',' . lnum2. 'call align#align_getchar()'
endfunction

function! align#align_getchar() range abort
	echon 'Char: '
	let char = nr2char(getchar())
	exe a:firstline . ',' . a:lastline . 'call align#align(char, 0, 0)'
endfunction

" |
" one | one | one | one
" twotwotwo | twotwotwo | twotwotwo
" three | three | three | Three
" four | four | four
" five | five | five

" |
" one 	 two two two 	 three 	 four
" four 	 three 	 two two two 	 one
" two two two 	 three 	 one 	 four
" three 	 one 	 four 	 two two two

" s
" josh wainwright
" race track spin
" standing start
" pins and needles
" like the racers

" =
" int a = 1
" double b = 2
" long c = 3
" int abc = 123
" int abdcefghijklmnop = 123456789
