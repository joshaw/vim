" Created:  Wed 13 Jan 2016
" Modified: Mon 25 Jan 2016
" Author:   Josh Wainwright
" Filename: langton.vim

" Implementation of Langton's Ant in Vim Script.

function! s:setup()
	call ScratchBuf()
" 	setlocal guifont=Square
	%delete _
	call append(0, repeat([repeat(' ', winwidth(0))], winheight(0)))
	$delete _

	setlocal virtualedit=all buftype=nofile nonumber norelativenumber nowrap
	setlocal nocursorcolumn nocursorline nolist colorcolumn=0 filetype=langton
	call cursor(line('$')/2, winwidth(0)/2)
endfunction

function! s:funcs(pat)
	let letters = split(a:pat, '.\zs')
	return map(letters, 'v:val == "R" ? "s:turnright" : v:val == "L" ? "s:turnleft" : "s:forward"')
endfunction

function! s:turnleft()
	let b:dir = ( ( b:dir - 1 ) % 4 + 4 ) % 4
endfunction

function! s:turnright()
	let b:dir = ( b:dir + 1 ) % 4
endfunction

function! s:forward()
	return
endfunction

function! s:moveforward(line, col) abort
	let newln = 0
	let newcol = 0
	if     b:dir == 0 " Up
		let newln = a:line - 1
		let newln = newln < 1 ? b:winheight : newln
		return [newln, newcol, 0]
	elseif b:dir == 1 " Right
		let newcol = a:col + 1
		let newcol = newcol > b:winwidth ? 1 : newcol
		return [newln, newcol, 0]
	elseif b:dir == 2 " Down
		let newln = a:line + 1
		let newln = newln > b:winheight ? 1 : newln
		return [newln, newcol, 0]
	elseif b:dir == 3 " Left
		let newcol = a:col - 1
		let newcol = newcol < 1 ? b:winwidth : newcol
		return [newln, newcol, 0]
	else
		echoerr "Error. Direction is" b:dir
	endif
" 	
" 	let newln = a:line + ( !(b:dir % 2) ? b:dir-1 : 0 )
" 	let newln = newln < 1 ? b:winheight : newln > b:winheight ? 1 : newln
" 
" 	let newcol = a:col + ( b:dir % 2 ? (-1*(b:dir-2)) : 0 )
" 	let newcol = newcol > b:winwidth ? 1 : newcol < 1 ? b:winwidth : newcol
	return [newln, newcol, 0]
endfunction

function! langton#langton(pat)
	if &filetype != 'langton'
		call s:setup()
	endif
	let b:winheight = max([winheight(0), line('$')])
	let b:winwidth  = max([winwidth(0), col('$')])
	let b:dir = 0

	let pat = s:funcs(a:pat)
	let lencs = len(a:pat)
	while 1
		let line = getline('.')
		let col = col('.')
		let lnr = line('.')

		let cn = ((char2nr(line[col-1]) + 1) % lencs ) + 32
		let c = nr2char(cn)
		call call(pat[cn-32], [])
		call setline(lnr, strpart(line, 0, col-1) . c . strpart(line, col))
		call cursor(s:moveforward(lnr, col))

		redraw
" 		sleep 10m
	endwhile
endfunction
