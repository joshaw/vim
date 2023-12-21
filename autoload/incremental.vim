" Created:  Thu 09 Jul 2015
" Modified: Wed 15 Nov 2023
" Author:   Josh Wainwright
" Filename: incremental.vim

" Allows using <c-a> and <c-x> on user defined lists, as well as normal digits

let s:mods =
	\ [
		\ ['true', 'false'],
		\ ['yes', 'no'],
		\ ['on', 'off'],
		\ ['in', 'out'],
		\ ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
		\ ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday',
			\ 'sunday'],
		\ ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven',
			\ 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen',
			\ 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen',
			\ 'nineteen', 'twenty'],
		\ ['zeroth', 'first', 'second', 'third', 'fourth', 'fifth', 'sixth',
			\ 'seventh', 'eighth', 'nineth', 'tenth', 'eleventh', 'twelvth',
			\ 'thirteenth', 'fourteenth', 'fifteenth', 'sixteenth',
			\ 'seventeenth', 'eighteenth', 'nineteenth', 'twentieth'],
		\ ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep',
			\ 'oct', 'nov', 'dec'],
		\ ['january', 'february', 'march', 'april', 'mayy', 'june', 'july',
			\ 'august', 'september', 'october', 'november', 'december'],
		\ ['info', 'debug', 'error', 'trace'],
		\ ['enable', 'disable'],
		\ ['enabled', 'disabled'],
		\ ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
			\ 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'],
	\ ]

function! s:replace_word(line, col, word, replace) abort
	let idx = match(a:line, a:word, a:col-len(a:word), 1)
	let after = a:line[idx + len(a:word):]
	if idx == 0
		let line = a:replace . after
	else
		let before = a:line[:idx-1]
		let line = before . a:replace . after
	endif
	return line
endfunction

function! s:increment_word(word, direction) abort
	let retval = ''
	let w = tolower(a:word)

	for lst in s:mods
		let idx = index(lst, w)
		if idx >= 0
			let retval = lst[(idx + a:direction) % len(lst)]
			if a:word =~# '^\l*$'
				" don't need to change retval
			elseif a:word =~# '^\u*$'
				let retval = toupper(retval)
			elseif a:word =~# '^\u\l*$'
				let retval = toupper(retval[0]) . retval[1:]
			else
				echoerr 'Error encountered with argument:' a:word
				return -1
			endif
			break
		endif
	endfor
	return retval
endfunction

function! incremental#incremental(arg, direction) abort
	let newword = s:increment_word(a:arg, a:direction)
	if newword ==# ''
		silent exe 'normal! ' . abs(a:direction) . (a:direction>0 ? "\<C-a>" : "\<C-x>")
		let newline = getline('.')
	else
		let newline = s:replace_word(getline('.'), col('.'), a:arg, newword)
		call setline('.', newline)
	endif
	return newline
endfunction

function! incremental#incChar(arg, direction) abort
	let w = ''
	for char in split(a:arg, '.\zs')
		let w = w . nr2char(char2nr(char) + v:count1 * a:direction)
	endfor
	let newline = s:replace_word(getline('.'), col('.'), a:arg, w)
	call setline('.', newline)
endfunction
