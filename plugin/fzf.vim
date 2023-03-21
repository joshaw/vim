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

let s:fzf_sh = expand("<script>:h") . "/fzf.sh"
command! -nargs=? FGrep call <SID>InteractiveOpen("sh " . s:fzf_sh . " fuzzy_grep " . shellescape("<args>"))
command! -nargs=? FOpen call <SID>InteractiveOpen("sh " . s:fzf_sh . " fuzzy_open " . shellescape("<args>"))
command! -nargs=? FTag call <SID>InteractiveOpen("sh " . s:fzf_sh . " fuzzy_tag " . shellescape("<args>"))

function! <SID>FBuffers()
	let buffers = filter(range(1, bufnr("$")), "bufexists(v:val)")
	let list = map(buffers, "printf('%s %s', v:val, getbufinfo(v:val)[0].name)")

	let tempfile = tempname()
	call writefile(list, tempfile)
	call <SID>InteractiveOpen("< " . tempfile . " fzf --nth=2 | awk '{printf \"buffer %s\", $1}'")
endfunction

command! -nargs=0 FBuf call <SID>FBuffers()
