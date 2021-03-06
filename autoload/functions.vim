" Created:  Mon 12 Jan 2015
" Modified: Thu 31 Mar 2016
" Author:   Josh Wainwright
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

" Toggle Comment {{{1
function! functions#toggleComment() abort
	let dict = {
			\ 'bash': '#',
			\ 'c': '//',
			\ 'conf': '#',
			\ 'cpp': '//',
			\ 'dosbatch': '::',
			\ 'dot': '//',
			\ 'gitconfig': '#',
			\ 'gnuplot': '#',
			\ 'haskell': '--',
			\ 'java': '//',
			\ 'lua': '--',
			\ 'mail': '>',
			\ 'make': '#',
			\ 'markdown': '<!--',
			\ 'perl': '#',
			\ 'python': '#',
			\ 'ruby': '#',
			\ 'sh': '#',
			\ 'tex': '%',
			\ 'vim': '"',
			\ 'zsh': '#',
			\ }
	if has_key(dict, &filetype)
		let c = dict[&filetype]
		exe 's@^@'.c.' @ | s@^'.c.' '.c.' @@e'
		call histdel('search', -1)
		call histdel('search', -1)
	else
		echo &filetype . ': no comment char.'
	endif
endfun
function! functions#toggleCommentmap(type) abort
	let [lnum1, lnum2] = [line("'["), line("']")]
	exe lnum1 . ',' . lnum2. 'call functions#toggleComment()'
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

" Count occurances {{{1
function! functions#count(...) range abort
	let w = winsaveview()
	let word = @/

	redir => soutput
		exe 'silent %s#\V' . word . '##nge'
	redir END

	let soutput = soutput[1:]
	echo '"' . word . '": ' . soutput

	call histdel('/', -1)
	call winrestview(w)
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
" 	return "\<c-x>\<c-u>"
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

" Mirror {{{1
function! s:mirror(str)
	return join(reverse(split(a:str, '.\zs')), '')
endfunction

" Buffer Navigation {{{1
function! functions#buffernext(incr) abort
	let current = bufnr('%')
	let last = bufnr('$')
	let newnr = current + a:incr
	while 1
		if newnr != 0 && bufexists(newnr) && buflisted(newnr)
			silent execute ':buffer '.newnr
			break
		else
			let newnr += a:incr
			if newnr < 1
				let newnr = last
			elseif newnr > last
				let newnr = 1
			endif
			if newnr == current
				break
			endif
		endif
	endwhile
	let mes = printf('Buffer %s/%s', current, last)
	echo mes
endfunction

" Test Features {{{1
function! functions#testfeatures()
	let feats = []
	for feat in ['conceal', 'autocmd', 'eval', 'lua', 'persistent_undo', 'python',
				\ 'python3', 'visual']
		if ! has(feat)
			call add(feats, 'Missing: ' . feat)
		endif
	endfor
	for feat in ['hangul_input', 'netbeans_intg', 'mzscheme', 'tcl']
		if has(feat)
			call add(feats, 'Remove: ' . feat)
		endif
	endfor
	if empty(feats)
		echo "All present and correct"
	else
		for feat in feats
			echo feat
		endfor
	endif
endfunction

" Convert Transactions {{{1
function! functions#converttransactions()
	" Convert dates from dd/mm/yyyy to yyyymmdd
" 	echo a:firstline a:lastline
" 	exe a:firstline . ',' . a:lastline . 's#\v(\d{2})/(\d{2})/(\d{4})#\3\2\1#ge'
" 	" Remove quotes and replace commas inside quotes with #
" 	exe a:firstline . ',' . a:lastline . 's/' .
" 				\ '"\([^,"]\{-1,}\(,[^,"]\{-}\)\{-}\)"/' .
" 				\ '\=substitute(submatch(1), ",", "#", "g")/g'
	%s#\v(\d{2})/(\d{2})/(\d{4})#\3\2\1#ge
	" Remove quotes and replace commas inside quotes with #
	%s/"\([^,"]\{-1,}\(,[^,"]\{-}\)\{-}\)"/\=substitute(submatch(1), ",", "#", "g")/ge
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
			echo '    ' . buf
		endfor
	endif
endfunction
