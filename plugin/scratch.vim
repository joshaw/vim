" Created:  Tue 12 Jan 2016
" Modified: Tue 12 Jan 2016
" Author:   Josh Wainwright
" Filename: scratch.vim

function! ScratchBuf() abort
	for buf in range(1, bufnr('$')+1)
		if bufexists(buf)
			let bt = getbufvar(buf, '&buftype')
			if bt == 'nofile'
				if bufwinnr(buf) > 0
					exe bufwinnr(buf) . 'wincmd w'
				else
					exe 'buffer!' buf
				endif
				break
			endif
		endif
		if buf == bufnr('$')
			enew
		endif
	endfor
endfunction
