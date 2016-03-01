" Created:  Mon 01 Feb 2016
" Modified: Fri 12 Feb 2016
" Author:   Josh Wainwright
" Filename: calc.vim

function! calc#calc()
	setlocal buftype=nofile
	setlocal filetype=calc
	call s:recalculate()
	call Update_var_section()
	augroup calc_calc
		autocmd!
		autocmd TextChanged <buffer> call Check_line_recalculate()
		autocmd TextChangedI <buffer> call Check_line_recalculate()
	augroup END

	syntax match Define   "^[^=]\+=[^=]\+$"
	syntax match Function "^\l\s*[+-]\?=.*"
	syntax match Comment "^#.*$"
	syntax region Comment start="\%^" end="^-*$"
endfunction

function! Check_var_section() abort
	for lnr in range(1, min([line('$'), 14]))
		if getline(lnr) =~# '^-\+$'
			return lnr
		endif
	endfor
	return 0
endfunction

function! Update_var_section() abort
	let letters = []
	let lines = ['']
	let l = 0
	for letr in range(97, 122)
		let letter = nr2char(letr)
		if exists('b:{letter}') && b:{letter} !=# 0
			let letter_add = '    ' . letter . ' = ' . string(b:{letter})
			call add(letters, letter_add)

			if strdisplaywidth(lines[l] . letter_add) > &tw
				let l += 1
				call add(lines, '')
			endif
			let lines[l] .= letter_add
		endif
	endfor

	call add(lines, repeat('-', &l:tw))
	let sepline = Check_var_section()
	if sepline > 0
		silent exe '0,' . sepline . 'delete _'
	endif
	call append(0, lines)
endfunction

function! s:exe(cmd)
	let cmd = s:replace_consts(a:cmd)
	if cmd[-1:-1] =~# '!'
		exe cmd[0:-2]
	else
		try
			exe cmd
		catch
		endtry
	endif
endfunction

function! s:eval(cmd)
	let cmd = s:replace_consts(a:cmd)
	if cmd[-1:-1] =~# '!'
		return eval(cmd[0:-2])
	else
		try
			return eval(cmd)
		catch
		endtry
	endif
endfunction

function! s:replace_consts(line)
	let line = substitute(a:line, '\CPI', '3.141592653589793', 'g')
	let line = substitute(line  , '\CE' , '2.71828182846', 'g')
	return line
endfunction

function! Check_line_recalculate()
	let save_cursor = getcurpos()
	let line = getline('.')
	if line =~# '^#' || line =~# '^-*$'
		return
	else
		call s:recalculate()
	endif
	call setpos('.', save_cursor)
endfunction

function! s:recalculate()
	for lnr in range(Check_var_section(), line('$'))
		let line = getline(lnr)
		if line[0] ==# '#'
			continue
		elseif line =~# '^[a-z]\s*[+-]\?='
			exe 'unlet! b:' . line[0]
			sandbox call s:exe('let b:' . line)
		elseif count(split(line, '.\zs'), '=') == 1
			let [ques, null] = split(line, '=', 1)
			sandbox let ans = s:eval(ques)
			let newline = ques . '= ' . string(ans)
			call setline(lnr, newline)
		endif
	endfor
	call Update_var_section()
endfunction
