" Created:  Mon 11 Jan 2016
" Modified: Thu 31 Mar 2016
" Author:   Josh Wainwright
" Filename: cal.vim

let s:TRANS_YEAR = 1752
let s:TRANS_MONTH = 8 " September
let s:TRANS_DAY = 2

" Calculate Calendar functions {{{
function! s:isleap(year, cal)
	if a:cal == "GREGORIAN"
		if a:year % 400 == 0
			return 1
		elseif a:year % 100 == 0
			return 0
		endif
		return (a:year % 4 == 0 )
	else " a:cal == "JULIAN"
		return (a:year % 4 == 0)
	endif
endfunction

function! s:monthlength(year, month, cal)
	let mdays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	return (a:month == 1 && s:isleap(a:year, a:cal) ? 29 : mdays[a:month])
endfunction

function! s:dayofweek(year, month, dom, cal)
	let a = (13 - a:month) / 12
	let y = a:year - a
	let m = a:month + 12 * a - 1

	if a:cal == "GREGORIAN"
		return (a:dom + y + y/4 - y/100 + y/400 + (31*m)/12) % 7
	else " a:cal == "JULIAN"
		return (5 + a:dom + y + y/4 + (31*m)/12) % 7
	endif
endfunction

function! s:getgrid(year, month, line)
	let ret = ""
	let cal = (a:year < s:TRANS_YEAR || (a:year == s:TRANS_YEAR
				\ && a:month <= s:TRANS_MONTH)) ? "JULIAN" : "GREGORIAN"
	let trans = (a:year == s:TRANS_YEAR && a:month == s:TRANS_MONTH)
	let offset = s:dayofweek(a:year, a:month, 1, cal) - 1
	if offset < 0
		let offset += 7
	endif
	
	let d = 0
	if a:line == 1
		while ( d < offset )
			let ret .= printf("%s", "   ")
			let d += 1
		endwhile
		let dom = 1
	else
		let dom = 8 - offset + (a:line - 2) * 7
		if ( trans )
			let dom += 11
		endif
	endif

	let today = filter(split(strftime("%Y %m %d")), "str2nr(v:val)")
	let thismonth = (a:year == today[0] && a:month+1 == today[1])
	while ( d < 7 && dom <= s:monthlength(a:year, a:month, cal) )
		if ( thismonth && dom == today[2] )
			let ret .= printf("%2d|", dom)
		elseif (exists("g:highlight_dates") &&
					\ has_key(g:highlight_dates, a:month+1) &&
					\ index(g:highlight_dates[a:month+1], dom) >= 0)
			let ret .= printf("%2d#", dom)
		else
			let ret .= printf("%2d ", dom)
		endif
		if ( trans && dom == s:TRANS_DAY )
			let dom += 11
		endif
		let d += 1
		let dom += 1
	endwhile

	while ( d < 7 )
		let ret .= printf("%s", "   ")
		let d += 1
	endwhile

	return ret
endfunction

function! s:getcal(year, month, showyear)
	let cal = []
	let smon = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
				\ 'August', 'September', 'October', 'November', 'December' ]
	let days = [ 'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']

	let month = a:month % 12
	let mon_name = smon[month] . (a:showyear ? ' ' . a:year : '')
	let mon_line = s:center(20, mon_name)
	call add(cal, printf("%-21s", mon_line))

	let dow = 1
	let line = ''
	while ( dow < (1 + 7) )
		let line .= days[dow % 7] . ' '
		let dow += 1
	endwhile
	call add(cal, line)

	let line = 1
	while ( line <= 6 )
		call add(cal, s:getgrid(a:year, month, line))
		let line += 1
	endwhile
	return cal
endfunction

" }}}

" Draw Calendar functions {{{
function! s:highlightline(line)
	if stridx(a:line, '|') > 0
		let split = split(a:line, '|', 1)
		echo ""
		echon split[0][0:-3]
		echohl DiffText
		echon split[0][-2:]
		echohl None
		echon ' ' . split[1]
		echo ""
	else
		echo a:line
	endif
endfunction

function! s:center(width, str) abort
	let width = (a:width - strdisplaywidth(a:str)) / 2
	return repeat(' ', width) . a:str
endfunction

function! s:drawcal(year, month)
	for i in s:getcal(a:year, a:month, 1)
		call s:highlightline(i)
	endfor
endfunction

function! s:drawyear(draw, year, cols)
	let cals = []
	let calbuf = []
	for i in range(0, 11)
		call add(cals, s:getcal(a:year, i, 0))
	endfor

	let yearline = s:center((20 * a:cols + 2 * (a:cols)), a:year)
	if a:draw
		echo printf("%s\n\n", yearline)
	else
		call extend(calbuf, [yearline, ''])
	endif

	for n in range(0, 11, a:cols)
		for i in range(0, 7)
			let line = ''
			for j in range(n, n+a:cols-1)
				try
					let line .= cals[j][i] . '  '
				catch /^Vim\%((\a\+)\)\=:E684/
				endtry
			endfor
			if a:draw
				call s:highlightline(line)
			else
				call add(calbuf, line)
			endif
		endfor
	endfor
	return calbuf
endfunction


" }}}

" API {{{
function! cal#cal(wholeyear, ...)
	let len = len(a:000)
	if empty(a:000)
		if a:wholeyear
			call s:drawyear(1, strftime("%Y"), 3)
		else
			call s:drawcal(strftime("%Y"), strftime("%m") - 1)
		endif
	elseif len == 1
		if a:wholeyear
			call s:drawyear(1, a:1, 3)
		else
			call s:drawcal(strftime("%Y"), a:1 - 1)
		endif
	elseif len == 2
		if a:wholeyear
			call s:drawyear(1, a:1, a:2)
		else
			call s:drawcal(a:1, a:2 - 1)
		endif
	elseif len == 3
		let i = 0
		let year = a:1
		let mon = a:2
		while i < a:3
			call s:drawcal(year, mon - 1)
			let mon += 1
			if mon > 12
				let mon = 1
				let year += 1
			endif
			let i += 1
		endwhile
	else
		echo "Wrong number of arguments"
	endif
endfunction

function! cal#calbuf(...)
	call ScratchBuf()
	setlocal conceallevel=1 concealcursor=nv filetype=calendar nocursorcolumn
	setlocal nocursorline colorcolumn=0 nolist
	let b:year = a:0 > 0 ? a:1 : strftime("%Y")
	let yearcal = s:drawyear(0, b:year, 3)
	setlocal modifiable
	%delete _
	call append(0, yearcal)
	$delete _
	setlocal nomodified
	call cursor(1,1)
	call search('\d|', 'cW')
	echo "Year:" b:year
	nnoremap <silent><buffer> H :call cal#calbuf(b:year - 1)<cr>
	nnoremap <silent><buffer> L :call cal#calbuf(b:year + 1)<cr>
	nnoremap <silent><buffer> t :call cal#calbuf(strftime("%Y"))<cr>
	syntax match calendarKeyword "\d\{1,2}|" contains=calendarConceal
	syntax match calendarVariable "\d\{1,2}#" contains=calendarConceal
	syntax match calendarConceal "|\|#" conceal
	highlight! link Conceal Normal
endfunction

" }}}

" Clock {{{
function! s:setup()
	setlocal modifiable
	setlocal fileencoding=utf8 nonumber norelativenumber nocursorcolumn
	setlocal nocursorline colorcolumn=0 nolist
	let b:laststatus_save = &laststatus
	set laststatus=0
	%delete _
	call append(0, repeat([''], winheight(0)))
endfunction

function! s:teardown()
	exe 'set laststatus=' . b:laststatus_save
	setlocal number< relativenumber< cursorcolumn< cursorline< colorcolumn<
	setlocal list< modifiable
	%delete _
	autocmd! * <buffer>
endfunction

function! cal#clock()
	call ScratchBuf()
	call s:setup()
	let s:secs = 1
	if s:secs
		setlocal updatetime=1000
	else
		setlocal updatetime<
	endif
	call s:getfont(2)
	call s:doclock(s:secs)
	autocmd CursorHold <buffer> call s:doclock(s:secs)
	autocmd BufLeave <buffer> call s:teardown()
	nnoremap <buffer> + :call <SID>getfont((b:font + 1) % 3)<bar>call <SID>setup()<bar>call <SID>doclock(1)<cr>
	call cursor(1,1)
endfunction

function! s:doclock(secs)
	if a:secs
		let time = strftime("%Hc%Mc%S")
	else
		let time = strftime("%Hc%M")
	endif
	let nums = split(time, '\zs')
	let n = (winheight(0) - 3) / 2
	for i in range(0, len(s:n0)-1)
		let n += 1
		let line = ''
		for j in nums
			let line .= s:n{j}[i] . s:nsp[i]
		endfor
		let line = substitute(line, '#', '█', 'g')
		call setline(n, s:center(winwidth(0), line))
	endfor
	let date = strftime("%A %d %B %Y")
	call setline(n+2, s:center(winwidth(0), date))
	call feedkeys('', 'n')
	redraw!
endfunction

function! s:getfont(font)
	let b:font = a:font
	let fontarr = s:font{a:font}
	let font = fontarr['font']
	let letters = fontarr['letters']
	let height = len(font)
	let n = 0
	for letter in letters
		let s:n{letter} = []
		for line in range(0, height-1)
			call add(s:n{letter}, font[line][n])
		endfor
		let n += 1
	endfor
endfunction

let s:font0 = {'letters': ['sp', 'c', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'], 'font': [
\[' ',':','0','1','2','3','4','5','6','7','8','9']]}

let s:font1 = {'letters': ['sp' ,'c', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'], 'font': [
\[' ',' ','###',' # ','###','###','# #','###','###','###','###','###'],
\[' ','#','# #','## ','  #','  #','# #','#  ','#  ','  #','# #','# #'],
\[' ',' ','# #',' # ','###',' ##','###','###','###','  #','###','###'],
\[' ','#','# #',' # ','#  ','  #','  #','  #','# #','  #','# #','  #'],
\[' ',' ','###','###','###','###','  #','###','###','  #','###','  #']]}

let s:font2 = {'letters': ['sp', 'c', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'], 'font': [
\['  ','  ','########','   ##   ','########','########','##    ##','########','########','########','########','########'],
\['  ','##','##    ##','   ##   ','##    ##','      ##','##    ##','##      ','##      ','      ##','##    ##','##    ##'],
\['  ','##','##    ##','   ##   ','      ##','      ##','##    ##','##      ','##      ','      ##','##    ##','##    ##'],
\['  ','  ','##    ##','   ##   ','########','  ######','########','########','########','      ##','########','########'],
\['  ','##','##    ##','   ##   ','##      ','      ##','      ##','      ##','##    ##','      ##','##    ##','      ##'],
\['  ','##','##    ##','   ##   ','##      ','      ##','      ##','##    ##','##    ##','      ##','##    ##','      ##'],
\['  ','  ','########','   ##   ','########','########','      ##','########','########','      ##','########','########']]}

let s:font3 = {'letters': ['sp', 'c', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'], 'font': [
\['   ','  ','########','      ##','########','########','##    ##','########','########','########','########','########'],
\['   ','##','##    ##','      ##','      ##','      ##','##    ##','##      ','##      ','      ##','##    ##','##    ##'],
\['   ','##','##    ##','      ##','      ##','      ##','##    ##','##      ','##      ','      ##','##    ##','##    ##'],
\['   ','  ','##    ##','      ##','########','########','########','########','########','      ##','########','########'],
\['   ','##','##    ##','      ##','##      ','      ##','      ##','      ##','##    ##','      ##','##    ##','      ##'],
\['   ','##','##    ##','      ##','##      ','      ##','      ##','      ##','##    ##','      ##','##    ##','      ##'],
\['   ','  ','########','      ##','########','########','      ##','########','########','      ##','########','########']]}
