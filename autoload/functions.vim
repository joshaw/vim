" Created:  Mon 12 Jan 2015
" Modified: Fri 13 Nov 2015
" Author:   Josh Wainwright
" Filename: functions.vim

" GrepString {{{1
" Set the grepprg depending on context
function! functions#GrepString()
	if ( exists("b:git_dir") && b:git_dir != '')
				\ || isdirectory('.git')
				\ || isdirectory('../.git')
				\ || isdirectory('../../.git')
				\ || isdirectory('../../../.git')
				\ || isdirectory('../../../../.git')
		setlocal grepformat=%f:%l:%m
		setlocal grepprg=git\ --no-pager\ grep\ -H\ --line-number\ --no-color
					\\ --ignore-case\ -I\ -e
	elseif executable('ag')
		setlocal grepformat=%f:%l:%c:%m
		setlocal grepprg=ag\ --vimgrep\ --smart-case
	else
		setlocal grepformat=%f:%l:%m
		setlocal grepprg=grep\ --binary-files=without-match\ --with-filename
					\\ --line-number\ --dereference-recursive\ --ignore-case\ $*
	endif
endfunction

" BufGrep {{{1
" Search and Replace through all buffers
function! functions#BufGrep(search)
	cclose
	call setqflist([])
	silent! exe "bufdo vimgrepadd " . a:search . " %"
	copen
endfunction

" Sum {{{1
" Sum a visual selection of numbers
function! functions#Sum() range
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
		let s:n = substitute(s:n, '\v^[^0-9-]*\ze([0-9]|$)', '', "")
		if s:n == ''
			continue
		endif
		let s:num = str2float(s:n)
		if s:num != 0
			echon string(s:num) . ', '
			let s:sum = s:sum + s:num
		endif
	endfor
	echon " = " . string(s:sum)
endfunction

" BlockIncr {{{1
" Increment a blockwise selection
function! functions#BlockIncr(num) range
	let l:old = @/
	try
		'<,'>s/\v%V-?\d+/\=(submatch(0) + a:num)/
		call histdel('/', -1)
	catch /E486/
	endtry

	let @/ = l:old
endfunction

" Verbose {{{1
function! functions#Verbose(level, excmd)
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
function! functions#Oldfiles()
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

" iptables {{{1
function! functions#IPtablesSort()
	silent setlocal filetype=ipfilter
	1
	call search('^\[.\{-}:.\{-}\]')
	mark a
	$
	call search('DROP', 'b')
	mark b
	'a;'bs/^\v(\[\d+:\d+]) (-A.*DROP *)$/\2\1/
	'a;'b!sort -Vu
	$
	call search('DROP', 'b')
	mark b
	'a;'bs/^\v(-A.*DROP) (\[\d+:\d+\])$/\2 \1 /
	delmarks a b
endfunction

" Toggle Comment {{{1
function! functions#toggleComment()
	let dict = {
			\ 'bash': '#',
			\ 'c': '//',
			\ 'cpp': '//',
			\ 'dosbatch': '::',
			\ 'dot': '//',
			\ 'gnuplot': '#',
			\ 'haskell': '--',
			\ 'java': '//',
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
	if has_key(dict, &ft)
		let c = dict[&ft]
		exe "s@^@".c." @ | s@^".c." ".c." @@e"
		call histdel('search', -1)
		call histdel('search', -1)
	else
		echo &ft . ': no comment char.'
	endif
endfun
function! functions#toggleCommentmap(type)
	let [lnum1, lnum2] = [line("'["), line("']")]
	exe lnum1 . ',' . lnum2. 'call functions#toggleComment()'
endfunction

" NextFileinDir {{{1
function! functions#nextFileInDir(direction)
	let sep = has("win32") ? '\' : '/'
	let fn = expand('%:p:h')
	let files = extend(glob(fn.'/*', 0, 1), glob(fn.'/.[^.]*', 0, 1))
	call map(files, "fnamemodify(v:val, ':p')")
	call filter(files, "v:val[-1:] !=# sep")

	let tot = len(files)
	if tot > 0
		call sort(files)
		let index = index(files, expand('%:p'))
		exe 'edit' files[(index + a:direction) % tot]
	endif
endfunction

" Nroff formatting of HTML file {{{1
function! functions#html2nroff(...)
	let l:tw = a:0 > 0 ? a:1 : &tw
	silent StripTrailing
	keeppatterns silent! %s/<\(h\d\).\{-}>\(.\{-}\)<\/\1>/.tl '\2'''/
	keeppatterns silent! %s/<\(title\).\{-}>\(.\{-}\)<\/\1>/.ce 1\r\2/
	keeppatterns silent! %s/<.\{-}>//ge
	keeppatterns silent! %s/^\s\+//e
	keeppatterns silent! %s/\(“\|”\)/"/ge
	keeppatterns silent! %s/’/'/ge
	keeppatterns silent! %s/—/--/ge
	keeppatterns silent! %s/\s?…\s?/.../ge
	call append(0, '.ll '.l:tw)
	call append(0, '.nh')
	silent %!nroff
	silent StripTrailing
endfunction

" Count occurances {{{1
function! functions#count(...) range
	let w = winsaveview()
	let noecho = 0

	if a:0 == 1
		let word = a:1
	elseif a:0 == 2
		let word = a:1
		let noecho = !!a:2
	else
		let word = @/
	endif

	redir => soutput
		exe 'silent %s#\V' . word . '##nge'
	redir END

	let soutput = soutput[1:]
	let g:status_var = soutput + 0

	if !noecho
		echo '"' . word . '": ' . soutput
	endif

	call histdel('/', -1)
	call winrestview(w)
	return g:status_var
endfunction

" Smart completion on tab {{{1
function! functions#smart_TabComplete()
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
	if maparg(cword.'#', 'i', 1) != ''
		return "#\<c-]>"
	endif

	" Check for filenames
	let pat = '\v(^|[0-9A-Za-z_.~])(\/|\\){-1,2}([0-9A-Za-z_.~]|$)'
	if match(substr, pat) != -1
		return "\<c-x>\<c-f>"
	endif

	" Otherwise, default completion
	return "\<c-n>"
endfunction

" Show non-ascii characters {{{1
function! functions#AsciiToggle()
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

" Buffer Navigation {{{1
function! functions#buffernext(incr)
	let current = bufnr("%")
	let last = bufnr("$")
	let newnr = current + a:incr
	while 1
		if newnr != 0 && bufexists(newnr) && buflisted(newnr)
			silent execute ":buffer ".newnr
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
	echo printf('Buffer [%s/%s] %s', bufnr('%'), bufnr('$'), bufname('%'))
endfunction
