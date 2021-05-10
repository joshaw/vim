function! <SID>InteractiveOpen(cmd)
	let s:tempfile=tempname()

	function! <SID>read_file()
		try
			let output = readfile(s:tempfile, '', 1)
			if len(output) == 0
				echo "No file"
			else
				execute output[0]
			endif
		finally
			call delete(s:tempfile)
		endtry
	endfunction

	if has('nvim')
		let callback = {}
		function! callback.on_exit(id, code, type)
			call <SID>read_file()
		endfunction

		let cmd = a:cmd . ' >' . shellescape(s:tempfile)
		call functions#popup_cmd(cmd, "win", callback)
	else
		silent execute '!' . escape(a:cmd, '%!') . ' >' . shellescape(s:tempfile)
		call <SID>read_file()
		redraw!
	endif
endfunction

command! -nargs=? FGrep call <SID>InteractiveOpen("git grep -nI '<args>' | fzf --nth=3.. -d: | awk -F: '{printf \"edit +%i %s\", $2, $1}'")
command! -nargs=? FOpen call <SID>InteractiveOpen("git ls-files -c -o --exclude-standard | grep '<args>' | fzf --preview='head -$LINES {}' --preview-window='right:30%' | awk '{printf \"edit %s\", $1}'")
command! -nargs=? FTag call <SID>InteractiveOpen("grep -v '^!_TAG_' tags | grep '<args>' | fzf --nth=1 -d'\t' | awk '{printf \"tag %s\", $1}'")
