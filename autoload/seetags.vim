" Created:  Fri 04 Dec 2015
" Modified: Wed 06 Apr 2016
" Author:   Josh Wainwright
" Filename: seetags.vim

let s:sortstrings = ['id', 'name', 'kind', 'length']
let g:seetags = {'sort': 0, 'targetline': 0, 'fullkind': 0}

function! s:q_handle() abort
	let g:status_var = ''
	let l:alt = bufnr('#')
	if l:alt < 0 || bufnr('$') == 1
		enew
	elseif l:alt == bufnr('%')
		buffer 1
	else
		exe 'buffer' l:alt
	endif
	let &l:wrap = g:seetags['wrapsave']
	unlet g:seetags['tags']
endfunction

function! s:enter_handle() abort
	if line('.') == 1
		return
	endif
	" Line number based indexing - content of line doesn't matter
	let tag = g:seetags['tags'][line('.') - 2]
	exe 'edit' tag['fname']
	exe tag['cmd']
	silent! foldopen!
	let &l:wrap = g:seetags['wrapsave']
	unlet g:seetags['tags']
endfunction

function! s:f_handle() abort
	let g:seetags['fullkind'] = !g:seetags['fullkind']
	call <SID>display_tags()
endfunction

function! s:sort_handle(a1, a2)
	let n1 = a:a1[s:sortstrings[g:seetags['sort']]]
	let n2 = a:a2[s:sortstrings[g:seetags['sort']]]
	return n1 ==? n2 ? 0: n1 <? n2 ? -1 : 1
endfunction

function! s:toggle_sort(curline)
	" 0 = id, 1 = name, 2 = kind
	let g:seetags['sort'] = (g:seetags['sort'] + 1) % len(s:sortstrings)
	echo "Sorted by" s:sortstrings[g:seetags['sort']]
	let g:seetags['tags'] = sort(g:seetags['tags'], '<SID>sort_handle')
	call <SID>display_tags()
	call search(a:curline, 'cW')
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

	let startline = line('.')
	let g:seetags['tags'] = []
	let g:seetags['ctags'] = "ctags -f - --sort=no --excmd=number --fields=Klz '" . filename . "'"
	let tagsoutput = systemlist(g:seetags['ctags'])

	if v:shell_error
		echo "Error running Ctags"
		return
	elseif len(tagsoutput) == 0
		echo fnamemodify(filename, ':~:.') ": no tags found"
		return
	endif

	let id = 0
	let maxkw = 1
	for line in tagsoutput
		let id += 1
		let i1 = stridx(line, '	')
		let i2 = stridx(line, '	', i1 + 1)
		let i3 = stridx(line, ';"', i2 + 1)

		let name  = line[0    : i1-1]
		let fname = line[i1+1 : i2-1]
		let cmd   = line[i2+1 : i3-1]

		let linedict = {'id': id, 'name': name, 'fname': fname, 'cmd': cmd, 'length': len(name)}

		let rest = line[i3+2 : -1]
		for pair in split(rest, '\t')
			let idx = stridx(pair, ':')
			let key = pair[0 : idx-1]
			let value = pair[idx+1 : -1]
			call extend(linedict, {key : value})
		endfor

		" Get the tag that the cursor should start on
		if startline >= linedict['cmd']
			let g:seetags['targetline'] = linedict['id']
		endif

		" Find max length of kind
		let len = len(linedict['kind'])
		if len > maxkw
			let maxkw = len
		endif

		call add(g:seetags['tags'], linedict)
	endfor

	let g:seetags['tags'] = sort(g:seetags['tags'], '<SID>sort_handle')
	let g:seetags['kw'] = maxkw

	let g:seetags['wrapsave'] = &wrap
	let &l:wrap = 0
	call s:display_tags()
endfunction

function! s:display_tags()
	call ScratchBufHere()

	nnoremap <silent><buffer> q :call <SID>q_handle()<cr>
	nnoremap <silent><buffer> <cr> :call <SID>enter_handle()<cr>
	nnoremap <silent><buffer> <2-LeftMouse> :call <SID>enter_handle()<cr>
	nnoremap <silent><buffer> s :call <SID>toggle_sort(getline('.'))<cr>
	nnoremap <silent><buffer> f :call <SID>f_handle()<cr>
	nnoremap <silent><buffer> - q<cr>

	setlocal concealcursor=nc conceallevel=3 bufhidden=unload undolevels=-1
	setlocal nobuflisted buftype=nowrite noswapfile nowrap nolist
	setlocal cursorline colorcolumn="" foldcolumn=0 nofoldenable

	syntax clear
	syn region NavdTagsO matchgroup=NavdTagsHid start="^\w\+ \+" end="$"
	syn region NavdTagsf matchgroup=NavdTagsHid start="^f\%[unction] \+" end="$"
	syn region NavdTagsd matchgroup=NavdTagsHid start="^d\%[efine] \+" end="$"
	syn region NavdTagsi matchgroup=NavdTagsHid start="^i\%[nclude] \+" end="$"
	syn region NavdTagsm matchgroup=NavdTagsHid start="^m\%[acro] \+" end="$"
	syn region NavdTagst matchgroup=NavdTagsHid start="^t\%[ypedef] \+" end="$"
	syn region NavdTagss matchgroup=NavdTagsHid start="^s\%[tructure] \+" end="$"
	syn region NavdTagsv matchgroup=NavdTagsHid start="^v\%[ariable] \+" end="$"
	syn match NavdCurDir '\%^.*$'

	hi! link NavdTagsf    Function
	hi! link NavdTagsd    Macro
	hi! link NavdTagsi    Define
	hi! link NavdTagsm    Macro
	hi! link NavdTagst    Typedef
	hi! link NavdTagss    Structure
	hi! link NavdTagsv    Identifier
	hi! link NavdCurDir   SpecialComment
	hi! link NavdTagsHid  Comment

	setlocal modifiable
	silent %delete _
	call append(0, g:seetags['ctags'])
	if g:seetags['fullkind']
		let kw = g:seetags['kw']
		let cmd = 'printf("%-' . kw . 'S %S", v:val["kind"], v:val["name"])'
	else
		let cmd = 'v:val["kind"][0] . " " . v:val["name"]'
	endif
	call append(1, map(copy(g:seetags['tags']), cmd))
	$delete _

	setlocal nomodifiable

	let n = 1
	let cursorline = 1
	for l in g:seetags['tags']
		if l['id'] == g:seetags['targetline']
			let cursorline = n
			break
		endif
		let n += 1
	endfor

	call cursor(cursorline + 1, 1)
endfunction
