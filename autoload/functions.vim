" Created:	Mon 12 Jan 2015
" Modified: Wed 31 Jan 2024
" Author:	Josh Wainwright
" Filename: functions.vim

" BlockIncr {{{1
" Increment a blockwise selection
function! functions#BlockIncr(num) range abort
	let l:old = @/
	try
		'<,'>s/\v%V-?\d+/\=(submatch(0) + a:num)/
		call histdel('/', -1)
	catch /E486/
	endtry

	let @/ = l:old
endfunction

" Verbose {{{1
function! functions#Verbose(level, excmd) abort
  let temp = tempname()
  let verbosefile = &verbosefile
  call writefile([':'.a:level.'Verbose '.a:excmd], temp, 'b')
  return
		\ 'try|' .
		\ 'let &verbosefile = '.string(temp).'|' .
		\ 'silent '.a:level.'verbose exe '.string(a:excmd).'|' .
		\ 'finally|' .
		\ 'let &verbosefile = '.string(verbosefile).'|' .
		\ 'endtry|' .
		\ 'pedit '.temp.'|wincmd P|nnoremap <buffer> q :bd<CR>'
endfunction

" Oldfiles {{{1
function! functions#Oldfiles() abort
	let temp = tempname()
	call writefile(v:oldfiles, temp)
	exe 'pedit' temp
	wincmd P
	setlocal nobuflisted
	setlocal buftype=nofile
	setlocal bufhidden=delete
	setlocal noswapfile
	setlocal nomodifiable
	call cursor(0,0)
	nnoremap <buffer> <cr> :let f=expand('<cfile>') \| pclose \| exe 'e 'f<cr>
endfunction


" NextFileinDir {{{1
function! functions#nextFileInDir(direction) abort
	let sep = has('win32') ? '\' : '/'
	let fn = expand('%:p:h')
	let files = extend(glob(fn.'/*', 0, 1), glob(fn.'/.[^.]*', 0, 1))
	call map(files, "fnamemodify(v:val, ':p')")
	call filter(files, 'v:val[-1:] !=# sep')

	let tot = len(files)
	if tot > 0
		call sort(files)
		let index = index(files, expand('%:p'))
		exe 'edit' files[(index + a:direction) % tot]
	endif
endfunction

" Html2Text {{{1
function! functions#html2text(...) abort
	if !executable('iconv') || !executable('lynx')
		echoerr 'Required commands are not available (iconv, lynx)'
		return
	endif
	silent %!iconv -f utf-8 -t ascii//translit
	let tw = a:0 > 0 ? a:1 : &textwidth
	silent exe '%!lynx -justify -dump -stdin -width=' . tw
	return

	silent StripTrailing
	keeppatterns silent! %s/<\(h\d\).\{-}>\(.\{-}\)<\/\1>/.tl '\2'''/
	keeppatterns silent! %s/<\(title\).\{-}>\(.\{-}\)<\/\1>/.ce 1\r\2/
	keeppatterns silent! %s/<.\{-}>//ge
	keeppatterns silent! %s/^\s\+//e
	let l:tw = a:0 > 0 ? a:1 : &textwidth
	call append(0, '.ll '.l:tw)
	call append(0, '.nh')
	silent %!nroff
	silent StripTrailing
endfunction

" smart_TabCompete {{{1
" Smart completion on tab
function! functions#smart_TabComplete() abort
	" Check for existing completion menu
	if pumvisible()
		return "\<c-n>"
	endif

	" Check for start of line, or whitespace
	let linestart = strpart(getline('.'), -1, col('.'))
	let substr = matchstr(linestart, "[^ \t]*$")
	if strlen(substr) == 0
		return "\<tab>"
	endif

	" Check for abbreviations
	let cword = split(linestart)[-1]
	if maparg(cword.'#', 'i', 1) !=# ''
		return "#\<c-]>"
	endif

	" Check for filenames
	let pat = '\v(^|[0-9A-Za-z_.~])(\/|\\){-1,2}([0-9A-Za-z_.~]|$)'
	if match(substr, pat) != -1
		return "\<c-x>\<c-f>"
	endif

	" Otherwise, default completion
"	return "\<c-x>\<c-u>"
	return "\<c-n>"
endfunction

" Show non-ascii characters {{{1
function! functions#AsciiToggle() abort
	if exists('g:ascii_highlight')
		call matchdelete(g:ascii_highlight)
		unlet g:ascii_highlight
		let g:status_var = ''
	else
		let nonasciisearch = '[^\x00-\x7F]'
		highlight link NonAsciiChars Error
		let g:ascii_highlight = matchadd('NonAsciiChars', nonasciisearch)
		let @/ = nonasciisearch
		let g:status_var = 'NA'
	endif
endfunction

" Wall save all buffers {{{1
function! functions#Wall(quiet) abort
	let save_buffer = bufnr('%')
	let buflist = []
	for buf in range(1, bufnr('$'))
		if getbufvar(buf, '&modified')
			exe 'buffer ' . buf
			if a:quiet
				update!
			else
				update
			endif
			call add(buflist, bufname(buf))
		endif
	endfor

	" Return to previous place
	exec 'buffer ' . save_buffer

	if !a:quiet
		echo 'Wrote buffers:'
		for buf in buflist
			echo '	  ' . buf
		endfor
	endif
endfunction

" Sort selection {{{1
function! functions#sort_motion(mode) abort
	if a:mode == 'line'
		'[,']sort
	elseif a:mode == 'char'

	elseif a:mode == 'V'
		'<,'>sort
	endif
endfunction

" Indent sort {{{1
" Sorts blocks of lines using the indentation of the first line as the block
" delimiter. Useful for sorting things like yaml dicts where the indentation
" represents different keys.
function! functions#sort_indent() range abort
	let indent = substitute(getline('.'), '\(\s\+\).*', '\1', '')
	'>put ='END_OF_RANGE'
	exe "silent '<+1,'>substitute/^\\(" . indent . "\\S\\)/SORT_LINE\\1/"
	silent '<+1,'>vglobal/SORT_LINE/substitute/^/SOL_MARKER/
	'<,'>join!
	silent '<,'>substitute/SORT_LINE/\r/g
	'<,/^END_OF_RANGE$/sort
	silent '<,/^END_OF_RANGE$/substitute/SOL_MARKER/\r/ge
	/^END_OF_RANGE$/delete
endfunction


" Cadd - populate qflist with filename pattern {{{1
function! functions#cadd(cmd) abort
	let flist = systemlist(a:cmd)
	let list = []
	for f in flist
		call add(list, {"filename": f})
	endfor
	if len(list) > 0
		call setqflist(list)
		cfirst
	else
		echomsg "No files to add"
	endif
endfunction

" popup_cmd - run an interactive command in a popup window {{{1
function! functions#popup_cmd(cmd, relative, callback)
	autocmd TermClose * ++once :bw!

	let popup_width = 100
	let popup_height = 45
	let winnr = winnr()

	function! s:get_config() closure
		return {
			\ 'relative': 'win',
			\ 'row': 0,
			\ 'col': 0,
			\ 'width': winwidth(winnr),
			\ 'height': winheight(winnr),
			\ 'style': 'minimal',
		\ }
	endfunction
	function! s:get_config_centered()
		let w = min([250, &columns-10])
		let h = min([200, &lines-5])
		let col = (&columns - w) / 2
		let row = (&lines - h) / 2
		return {
			\ 'relative': 'editor',
			\ 'row': row,
			\ 'col': col,
			\ 'width': w,
			\ 'height': h,
			\ 'style': 'minimal',
			\ 'border': 'rounded'
		\ }
	endfunction

	let buf = nvim_create_buf(v:false, v:true)
	let s:float_win = nvim_open_win(buf, v:true, s:get_config())
	call nvim_win_set_option(s:float_win, 'winhl', 'NormalFloat:SignColumn')

	call termopen(a:cmd, a:callback)
	augroup popup_sigwinch
		autocmd!
		"autocmd Signal SIGWINCH silent! call nvim_win_set_config(s:float_win, s:get_config())
		autocmd Vimresized <buffer> call nvim_win_set_config(s:float_win, s:get_config())
	augroup END
	startinsert
	return buf
endfunction

" RemoveQFItem
function! functions#RemoveQFItem() range abort
	let qf_list = getqflist()

	if len(qf_list) > 0
		call remove(qf_list, a:firstline - 1, a:lastline - 1)
		call setqflist([], "r", {"items": qf_list})
		call cursor(a:firstline, 1)
	endif

	if len(qf_list) == 0
		cclose
	endif
endfunction

