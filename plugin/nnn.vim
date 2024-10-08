function! <SID>Nnn()
	let s:tempfile = tempname()
	let hidden = expand("%:p:t")[0] == "." ? ['-command', 'set hidden'] : []

	let start_path = expand('%:p')
	if ! filereadable(start_path)
		let start_path = expand('%:p:h')
	endif

	let pick_command = flatten(['lf', '-selection-path', s:tempfile, hidden, start_path])

	if has('nvim')
		let callback = {}
		function! callback.on_exit(id, code, type)
			try
				if filereadable(s:tempfile)
					silent execute 'edit ' . readfile(s:tempfile, '', 1)[0]
				endif
			finally
				call delete(s:tempfile)
			endtry
		endfunction

		let buf = functions#popup_cmd(pick_command, "win", callback)
		tnoremap <buffer> <c-z> :echo "Suspend disabled"<cr>
		augroup nnn
			autocmd!
			autocmd BufLeave <buffer> quit
		augroup END

	else
		silent execute '!' . join(pick_command, " ")
		try
			if filereadable(s:tempfile)
				silent execute 'edit ' . readfile(s:tempfile, '', 1)[0]
			endif
		finally
			call delete(s:tempfile)
		endtry
		redraw!
	endif
endfunction

command! -nargs=0 Nnn call <SID>Nnn()
