function! <SID>Nnn()
	let s:tempfile = tempname()
	let hidden = expand("%:p:t")[0] == "." ? ['-command', '"set hidden"'] : []

	let pick_command = join(flatten([
		\ 'lf',
		\ '-selection-path',
		\ s:tempfile,
		\ hidden,
		\ expand('%:p')
	\ ]), " ")

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
