" Created:  Thu 09 Jul 2015
" Modified: Mon 07 Sep 2015
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
			\ ['monday', 'tuesday', 'wednesday', 'thursday',
				\'friday', 'saturday', 'sunday'],
			\ ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven',
				\ 'eight', 'nine'],
			\ ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul',
				\'aug', 'sep', 'oct', 'nov', 'dec'],
			\ ['january', 'february', 'march', 'april', 'may', 'june', 'july',
				\ 'august', 'september', 'october', 'november', 'december'],
		\ ]

function! s:replace_word(line, col, word, replace)
	let idx = match(a:line, a:word, a:col-len(a:word), 1)
	let after = a:line[idx + len(a:word):]
	if idx == 0
		call setline('.', a:replace . after)
	else
		let before = a:line[:idx-1]
		call setline('.', before . a:replace . after)
	endif
endfunction

function! incremental#incremental(arg, direction)
	let retval = ''
	let w = tolower(a:arg)

	for lst in s:mods
		let idx = index(lst, w)
		if idx >= 0
			let retval = lst[(idx + v:count1*a:direction) % len(lst)]
			if a:arg =~# '^\l*$'
			elseif a:arg =~# '^\u*$'
				let retval = toupper(retval)
			elseif a:arg =~# '^\u\l*$'
				let retval = toupper(retval[0]) . retval[1:]
			else
				echoerr "Error encountered with argument:" a:arg
				return
			endif
			break
		endif
	endfor

	if retval == ''
		silent exe "normal! ".v:count1.(a:direction==1 ? "\<C-a>" : "\<C-x>")
	else
		call s:replace_word(getline('.'), col('.'), a:arg, retval)
	endif
endfunction

function! incremental#incrementalGlobal(arg, direction)
	let w = ''
	for char in split(a:arg, '.\zs')
		let w = w . nr2char(char2nr(char) + a:direction)
	endfor
	call s:replace_word(getline('.'), col('.'), a:arg, w)
endfunction
