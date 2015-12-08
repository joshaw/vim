" Created:  Fri 04 Dec 2015
" Modified: Tue 08 Dec 2015
" Author:   Josh Wainwright
" Filename: seetags.vim

let s:navd_fname = '__Navd__'
let s:sortstrings = ['id', 'name', 'kind']
let g:seetags = {'name': s:navd_fname, 'sort': 0, 'targetline': 0, 'fullkind': 0}

function! s:q_handle() abort
	let l:alt = expand('#')
	call clearmatches()
	let g:status_var = ''
	if l:alt ==# s:navd_fname
		enew
	else
		exe 'edit' l:alt
	endif
" 	quit
	let &l:wrap = g:seetags['wrapsave']
	unlet g:seetags['tags']
endfunction

function! s:enter_handle() abort
	if line('.') == 1
		return
	endif
	" Line number based indexing - content of line doesn't matter
	let tag = g:seetags['tags'][line('.') - 2]
" 	quit
	exe 'edit' tag['fname']
	exe tag['cmd']
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

function! s:toggle_sort()
	" 0 = id, 1 = name, 2 = kind
	let g:seetags['sort'] = (g:seetags['sort'] + 1) % len(s:sortstrings)
	echo "Sorted by" s:sortstrings[g:seetags['sort']]
	let g:seetags['tags'] = sort(g:seetags['tags'], '<SID>sort_handle')
	call <SID>display_tags()
endfunction

function! seetags#seetags(filename)
	if !executable('ctags')
		echo "Ctags not found"
		return
	endif

	let filename = (a:filename == '') ? expand('%') : a:filename
	let startline = line('.')
	let g:seetags['tags'] = []
	let g:seetags['ctags'] = 'ctags -f - --sort=no --excmd=number --fields=Klz ' . filename
	let tagsoutput = systemlist(g:seetags['ctags'])

	if len(tagsoutput) == 0
		echo fnamemodify(filename, ':~:.') ": no tags found"
		return
	elseif v:shell_error
		echo "Error running Ctags"
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

		let linedict = {'id': id, 'name': name, 'fname': fname, 'cmd': cmd}

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
	if bufname('%') !=# s:navd_fname
		exe 'silent! edit ' . s:navd_fname
" 		if bufexists(s:navd_fname) && bufwinnr(s:navd_fname) > 0
" 			exe bufwinnr(s:navd_fname) . 'wincmd w'
" 		else
" 			exe 'silent! 35vsplit ' . s:navd_fname
" 		endif
		setlocal filetype=navd

		nnoremap <silent><buffer> q :call <SID>q_handle()<cr>
		nnoremap <silent><buffer> <cr> :call <SID>enter_handle()<cr>
		nnoremap <silent><buffer> s :call <SID>toggle_sort()<cr>
		nnoremap <silent><buffer> f :call <SID>f_handle()<cr>
		nnoremap <silent><buffer> - q<cr>

		setlocal concealcursor=nc conceallevel=3 bufhidden=unload undolevels=-1
		setlocal nobuflisted buftype=nowrite noswapfile nowrap nolist
		setlocal cursorline colorcolumn="" foldcolumn=0 nofoldenable

		hi! link NavdTagsd    Macro
		hi! link NavdTagsf    Function
		hi! link NavdTagsi    Define
		hi! link NavdTagst    Typedef
		hi! link NavdTagss    Structure
		hi! link NavdTagsv    Identifier
		hi! link NavdTagsKind Comment
		hi! link NavdCurDir   SpecialComment
	endif

	syntax clear
	syn match NavdTagsKind "^\w\+" nextgroup=@NavdTag contains=NavdTagsHid
	if !g:seetags['fullkind']
		syn match NavdTagsHid  "^\w\zs\w\+ *\ze " conceal
	endif
	syn match NavdTagsd "\%(^define \+\)\@<=.*$"
	syn match NavdTagsf "\%(^function \+\)\@<=.*$"
	syn match NavdTagsi "\%(^include \+\)\@<=.*$"
	syn match NavdTagsd "\%(^macro \+\)\@<=.*$"
	syn match NavdTagst "\%(^typedef \+\)\@<=.*$"
	syn match NavdTagss "\%(^structure \+\)\@<=.*$"
	syn match NavdTagsv "\%(^variable \+\)\@<=.*$"
	syn cluster NavdTag contains=NavdTagsd,NavdTagsf,NavdTagsi,NavdTagst,NavdTagss,NavdTagsv
	syn match NavdCurDir '\%^.*$'

	setlocal modifiable

	silent %delete _
	call append(0, g:seetags['ctags'])
	let kw = g:seetags['kw']
	let cmd = 'printf("%-' . kw . 'S %S", v:val["kind"],  v:val["name"])'
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
