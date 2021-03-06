" Created:  Tue 12 Jan 2016
" Modified: Wed 02 Mar 2016
" Author:   Josh Wainwright
" Filename: scratch.vim

function! scratch#scratch(...) abort
	let anywhere = a:0 > 0 ? a:1 : 1
	for buf in range(1, bufnr('$')+1)
		if bufexists(buf)
			let bt = getbufvar(buf, '&buftype')
			if bt == 'nofile'
				if bufwinnr(buf) > 0 && anywhere
					exe bufwinnr(buf) . 'wincmd w'
				else
					exe 'buffer!' buf
				endif
				break
			endif
		endif
		if buf == bufnr('$')
			noswapfile enew
		endif
	endfor
	setlocal filetype<
	setlocal buftype=nofile
	setlocal bufhidden=hide
	setlocal modifiable
	silent %delete _
	silent! doautocmd BufLeave <buffer>
	autocmd! * <buffer>
	mapclear <buffer>
endfunction
