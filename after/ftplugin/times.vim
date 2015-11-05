" Created:  Sat 24 Jan 2015
" Modified: Wed 04 Nov 2015
" Author:   Josh Wainwright
" Filename: times.vim

function! Log_work_times()
	let l:today = strftime("%Y%m%d")
	let l:yesterday = strftime('%Y%m%d', localtime()-86400)
	let l:last = split(getline('$'), ",")[0]
	if l:today == l:last
		let l:newline = getline('$') . ", " . strftime("%H%M%S")
		call setline('$', l:newline)
	else
		let cnt = 1
		let newlines = []
		let l:prev = ''
		while l:prev != l:last
			let l:prev = strftime('%Y%m%d', localtime()-(86400 * cnt))
			let cnt += 1
			let newlines = add(newlines, l:prev . ", w     , w     , w     , w     , 1")
		endwhile
		call remove(newlines, -1)
		call append(line('$'), reverse(newlines))

		let l:newline = strftime("%Y%m%d") . ", " . strftime("%H%M%S")
		echo l:newline
		call append(line('$'), l:newline)
	endif
	call cursor('$', 1)
endfunction

nnoremap <buffer> <cr> :<c-u>call Log_work_times()<cr>

augroup log_work_times
	au!
	au BufReadPost,BufEnter times.txt call Log_work_times()
augroup END
