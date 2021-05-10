function! <SID>Nnn()
	let s:tempfile = tempname()
	let pick_command = 'lf -selection-path ' . s:tempfile . ' ' . expand('%:p')

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

		call functions#popup_cmd(pick_command, "win", callback)

	else
		silent execute '!' . pick_command
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
