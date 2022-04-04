" Created:	Mon 12 Jan 2015
" Modified: Wed 30 Mar 2022
" Author:	Josh Wainwright
" Filename: functions.vim

" BufGrep {{{1
" Search and Replace through all buffers
function! functions#BufGrep(search) abort
	cclose
	call setqflist([])
	silent! exe 'bufdo vimgrepadd ' . a:search . ' %'
	copen
endfunction

" Sum {{{1
" Sum a visual selection of numbers
function! functions#Sum() range abort
	let s:reg_save = getreg('"')
	let s:regtype_save = getregtype('"')
	let s:cb_save = &clipboard
	set clipboard&
	silent! normal! ""gvy
	let s:selection = getreg('"')
	call setreg('"', s:reg_save, s:regtype_save)
	let &clipboard = s:cb_save

	let s:sum = 0
	for s:n in split(s:selection, '[^0-9.-]')
		let s:n = substitute(s:n, '\v^[^0-9-]*\ze([0-9]|$)', '', '')
		if s:n ==# ''
			continue
		endif
		let s:num = str2float(s:n)
		if s:num != 0
			echon string(s:num) . ', '
			let s:sum = s:sum + s:num
		endif
	endfor
	echon ' = ' . string(s:sum)
endfunction

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
	autocmd TermClose * ++once :bd!

	let popup_width = 100
	let popup_height = 45

	if a:relative == "win"
		let opts = {
			\ 'relative': 'win',
			\ 'row': 0,
			\ 'col': 0,
			\ 'width': winwidth(0),
			\ 'height': winheight(0),
			\ 'style': 'minimal'
			\ }
	else
		let opts = {
			\ 'relative': 'editor',
			\ 'row': (&lines - popup_height) / 2,
			\ 'col': (&columns - popup_width) / 2,
			\ 'width': popup_width,
			\ 'height': popup_height,
			\ 'style': 'minimal'
			\ }
	endif

	let buf = nvim_create_buf(v:false, v:true)
	let float_win = nvim_open_win(buf, v:true, opts)
	"call nvim_win_set_option(float_win, 'winhl', 'Normal:Visual')

	call termopen(a:cmd, a:callback)
	startinsert
endfunction
