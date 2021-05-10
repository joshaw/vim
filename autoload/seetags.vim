" Created:  Fri 04 Dec 2015
" Modified: Wed 26 Aug 2020
" Author:   Josh Wainwright
" Filename: seetags.vim

function! <SID>sort_list(i1, i2)
	let a1 = str2nr(a:i1['lnum'])
	let a2 = str2nr(a:i2['lnum'])
	return a1 == a2 ? 0 : a1 > a2 ? 1 : -1
endfunction

function! seetags#seetags(filename)
	if !executable('ctags')
		echo "Ctags not found"
		return
	endif

	let filename = (a:filename == '') ? expand('%') : a:filename

	if empty(filename)
		echo "No file for Ctags"
		return
	endif

	let fext = fnamemodify(filename, ':e')

	let ctags_cmd = "ctags -f - --sort=no --excmd=number --fields=Klz --guess-language-eagerly " . filename
	let tagsoutput = systemlist(ctags_cmd)

	if v:shell_error
		echo "Error running Ctags"
		echo ctags_cmd
		return
	endif

	if len(tagsoutput) == 0
		echo fnamemodify(filename, ':~:.') ": no tags available"
		return
	endif

	let id = 0
	let maxkw = 1
	let loclist = []
	for line in tagsoutput
		let id += 1
		let i1 = stridx(line, '	')
		let i2 = stridx(line, '	', i1 + 1)
		let i3 = stridx(line, ';"', i2 + 1)

		let name  = line[0    : i1-1]
		let fname = line[i1+1 : i2-1]
		let cmd   = line[i2+1 : i3-1]

		let linedict = {'id': id, 'name': name, 'fname': fname, 'cmd': cmd}

		let rest = line[i3+2 : -1]
		for pair in split(rest, '\t')
			let idx = stridx(pair, ':')
			let key = pair[0 : idx-1]
			let value = pair[idx+1 : -1]
			call extend(linedict, {key : value})
		endfor

		call add(loclist, {
			\ "filename": fname,
			\ "lnum": cmd,
			\ "text": linedict['kind'] . ' - ' . name,
		\ })
	endfor

	call sort(loclist, "<SID>sort_list")
	call setloclist(0, loclist)
	call setloclist(0, [], 'a', {'title': 'TOC'})
	let save_win = winsaveview()
	lbefore
	call winrestview(save_win)
	lopen
endfunction
