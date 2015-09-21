" Created:  Mon 12 Jan 2015
" Modified: Fri 18 Sep 2015
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
		let s:n = substitute(s:n, '\v^[^0-9]*\ze([0-9]|$)', '', "")
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
	Verbose oldfiles
	0delete _
	silent %s/\v\d+: //
	setlocal nobuflisted
	setlocal buftype=nofile
	setlocal bufhidden=delete
	setlocal noswapfile
	setlocal nomodifiable
	normal gg
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

" FirstTimeRun {{{1
function! functions#FirstTimeRun()
	" Install vim-plug
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

	" Make folders if they don't already exist.
	if !isdirectory(expand(&undodir))
		call mkdir(expand(&undodir), "p")
		call mkdir(expand(&backupdir), "p")
		call mkdir(expand(&directory), "p")
	endif
endfunction

" Toggle Comment {{{1
function! functions#toggleComment(ft)
	let dict = {
			\ 'bash': '#',
			\ 'c': '//',
			\ 'cpp': '//',
			\ 'dosbatch': '::',
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
	if has_key(dict, a:ft)
		let c = dict[a:ft]
		exe "s@^@".c." @ | s@^".c." ".c." @@e"
		call histdel('search', -1)
		call histdel('search', -1)
	endif
endfun

" N/P file in dir {{{1
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
function! s:get_visual_selection()
  " Why is this not a built-in Vim script function?!
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

function! functions#count(mode) range
	let w = winsaveview()

	if a:mode ==# 'normal'
		let word = expand('<cword>')
		let word = '\<' . escape(word, '#\\') . '\>'
	elseif a:mode ==# 'visual'
		let word = s:get_visual_selection()
		let word = escape(word, '#\\')
	endif

	redir => soutput
		exe 'silent %s#\V' . word . '##nge'
	redir END
	let soutput = soutput[1:]
	let g:status_var = soutput + 0
	echo '"' . word . '": ' . soutput
	call histdel('/', -1)
	call winrestview(w)
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
