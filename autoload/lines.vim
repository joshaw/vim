" Created:  Mon 29 Feb 2016
" Modified: Thu 03 Mar 2016
" Author:   Josh Wainwright
" Filename: lines.vim

function! lines#randomlines()
	%s/.*//g
	setlocal nohlsearch

	let prevrand = 2
	py import random
	while 1
		let pos = getpos('.')
		let attop = 0
		let atbottom = 0
		let atleft = 0
		let atright = 0

		if pos[1] == 1
			let attop = 1
		elseif pos[1] == line('$')
			let atbottom = 1
		endif

		if pos[2] == 1
			let atleft = 1
		elseif pos[2] == strlen(getline('.'))
			let atright = 1
		endif

		if prevrand == 2
			let random = pyeval('random.choice([2,2,2,2,4,6])')
		elseif prevrand == 4
			let random = pyeval('random.choice([2,4,4,4,4,8])')
		elseif prevrand == 6
			let random = pyeval('random.choice([2,6,6,6,6,8])')
		elseif prevrand == 8
			let random = pyeval('random.choice([4,6,8,8,8,8])')
		else
			continue
		endif

		if pos[1] == 1 && random == 8
			continue
		elseif pos[2] == 1 && random == 4
			continue
		elseif pos[1] == line('$') && random == 2
			continue
		elseif pos[2] == strlen(getline('.')) && random == 6
			continue
		endif
				
		let prevrand = random
		call lines#key(random)
		redraw
		sleep 10m
	endwhile
endfunction

function! lines#lines()
	if exists("b:drawlines")
		mapclear <buffer>
		unlet b:drawlines
	else
		for i in range(1,9)
			exe 'nnoremap <buffer>' i ':call lines#key(' i ')<cr>'
		endfor
		let b:drawlines = 1
	endif
	set virtualedit=all
endfunction

function! s:insert_move(oldchar, char, dir)
	if !empty(a:oldchar)
		call s:setchar(a:oldchar)
	endif
	exe 'normal' a:dir
	call s:setchar(a:char)
endfunction

function! s:getchar()
	normal "qyl
	return @q
endfunction

function! s:setchar(char)
	exe "normal r" . a:char
endfunction

let s:cs = ['│', '─', '┌', '┐', '└', '┘']
let s:cs = ['║', '═', '╔', '╗', '╚', '╝']

function! lines#key(key)
	if a:key == 2
		if s:getchar() ==# s:cs[1]
			if b:prevkey == 4
				call s:insert_move(s:cs[2], s:cs[0], 'j')
			else
				call s:insert_move(s:cs[3], s:cs[0], 'j')
			endif
		else
			call s:insert_move('', s:cs[0], 'j')
		endif
	elseif a:key == 4
		if s:getchar() ==# s:cs[0]
			if b:prevkey == 2
				call s:insert_move(s:cs[5], s:cs[1], 'h')
			else
				call s:insert_move(s:cs[3], s:cs[1], 'h')
			endif
		else
			call s:insert_move('', s:cs[1], 'h')
		endif
	elseif a:key == 5
		call s:setchar(' ')
	elseif a:key == 6
		if s:getchar() ==# s:cs[0]
			if b:prevkey == 2
				call s:insert_move(s:cs[4], s:cs[1], 'l')
			else
				call s:insert_move(s:cs[2], s:cs[1], 'l')
			endif
		else
			call s:insert_move('', s:cs[1], 'l')
		endif
	elseif a:key == 8
		if s:getchar() ==# s:cs[1]
			if b:prevkey ==# 4
				call s:insert_move(s:cs[4], s:cs[0], 'k')
			else
				call s:insert_move(s:cs[5], s:cs[0], 'k')
			endif
		else
			call s:insert_move('', s:cs[0], 'k')
		endif
	endif
	let b:prevkey = a:key
endfunction

" let s:cs = ['|', '/', '-', '\', '+']
" function! lines#lines(key)
" 	if a:key == 1
" 		if s:getchar() ==# s:cs[2]
" 			call s:insert_move('.', s:cs[1], 'jh')
" 		elseif s:getchar() ==# s:cs[3]
" 			if b:prevkey == 7
" 				call s:insert_move('^', s:cs[1], 'jh')
" 			else
" 				call s:insert_move('', s:cs[1], 'jh')
" 			endif
" 		else
" 			call s:insert_move('', s:cs[1], 'jh')
" 		endif
" 	elseif a:key == 2
" 		if s:getchar() ==# s:cs[2]
" 			call s:insert_move(s:cs[4], s:cs[0], 'j')
" 		else
" 			call s:insert_move('', s:cs[0], 'j')
" 		endif
" 	elseif a:key == 3
" 		if s:getchar() ==# s:cs[2]
" 			call s:insert_move('.', s:cs[3], 'jl')
" 		elseif s:getchar() ==# s:cs[1]
" 			if b:prevkey == 1
" 				call s:insert_move('', s:cs[3], 'jl')
" 			else
" 				call s:insert_move('^', s:cs[3], 'jl')
" 			endif
" 		else
" 			call s:insert_move('', s:cs[3], 'jl')
" 		endif
" 	elseif a:key == 4
" 		if s:getchar() ==# s:cs[0]
" 			call s:insert_move(s:cs[4], s:cs[2], 'h')
" 		elseif s:getchar() ==# s:cs[3]
" 			call s:insert_move('.', s:cs[2], 'h')
" 		elseif s:getchar() ==# s:cs[1]
" 			call s:insert_move("'", s:cs[2], 'h')
" 		else
" 			call s:insert_move('', s:cs[2], 'h')
" 		endif
" 	elseif a:key == 5
" 		call s:setchar(' ')
" 	elseif a:key == 6
" 		if s:getchar() ==# s:cs[0]
" 			call s:insert_move(s:cs[4], s:cs[2], 'l')
" 		elseif s:getchar() ==# s:cs[3]
" 			if b:prevkey ==# 7
" 				call s:insert_move('.', s:cs[2], 'l')
" 			else
" 				call s:insert_move("'", s:cs[2], 'l')
" 			endif
" 		elseif s:getchar() ==# s:cs[1]
" 			call s:insert_move('.', s:cs[2], 'l')
" 		else
" 			call s:insert_move('', s:cs[2], 'l')
" 		endif
" 	elseif a:key == 7
" 		if s:getchar() ==# s:cs[2]
" 			call s:insert_move("'", s:cs[3], 'hk')
" 		elseif s:getchar() ==# s:cs[1]
" 			if b:prevkey == 9
" 				call s:insert_move('', s:cs[3], 'hk')
" 			else
" 				call s:insert_move('v', s:cs[3], 'hk')
" 			endif
" 		else
" 			call s:insert_move('', s:cs[3], 'hk')
" 		endif
" 	elseif a:key == 8
" 		if s:getchar() ==# s:cs[2]
" 			call s:insert_move(s:cs[4], s:cs[0], 'k')
" 		else
" 			call s:insert_move('', s:cs[0], 'k')
" 		endif
" 	elseif a:key == 9
" 		if s:getchar() ==# s:cs[2]
" 			call s:insert_move("'", s:cs[1], 'kl')
" 		elseif s:getchar() ==# s:cs[3]
" 			if b:prevkey == 7
" 				call s:insert_move('', s:cs[1], 'kl')
" 			else
" 				call s:insert_move('v', s:cs[1], 'kl')
" 			endif
" 		else
" 			call s:insert_move('', s:cs[1], 'kl')
" 		endif
" 	endif
" 	let b:prevkey = a:key
" endfunction
