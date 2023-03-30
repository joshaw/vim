" Created:  Sun 26 Apr 2015
" Modified: Wed 29 Mar 2023
" Author:   Josh Wainwright
" Filename: plugins.vim

" Timestamp
augroup timestamp
	autocmd!
	autocmd! BufRead * :call timestamp#Timestamp()
augroup END

"Whitespace
command! -range=% -nargs=0 StripTrailing :call whitespace#StripTrailing(<line1>,<line2>)
command! -nargs=0 TrimEndLines :call whitespace#TrimEndLines()
command! -nargs=0 Fmt :call whitespace#Fmt()

" Super Retab
command! -nargs=? -range=% Space2Tab call super_retab#IndentConvert(<line1>,<line2>,0,<q-args>)
command! -nargs=? -range=% Tab2Space call super_retab#IndentConvert(<line1>,<line2>,1,<q-args>)
command! -nargs=? -range=% RetabIndent call super_retab#IndentConvert(<line1>,<line2>,&et,<q-args>)

" DiffOrig
" View the difference between the buffer and the file the last time it was saved
"command! Diff :w !diff --color=always --unified % - || true

" Verbose
command! -range=999998 -nargs=1 -complete=command Verbose
      \ :exe functions#Verbose(<count> == 999998 ? '' : <count>, <q-args>)

" Oldfiles
command! -nargs=0 Oldfiles :call functions#Oldfiles()

" Html2Text
command! -nargs=? -bar Html2Text :call functions#html2text(<args>)

" Show non-ascii characters in text
command! -nargs=0 -bar AsciiToggle :call functions#AsciiToggle()

" Align text on character
command! -range=% -nargs=? -bang Align :<line1>,<line2>call align#align('<args>', <bang>0, 0)
command! -range=% -nargs=? -bang AlignR :<line1>,<line2>call align#align('<args>', <bang>0, 1)

" Calendar
command! -nargs=* -bang -bar Cal :call cal#cal(<bang>0, <f-args>)
command! -nargs=* -bar CalBuf :call cal#calbuf(<f-args>)
command! -nargs=0 Clock :call cal#clock()

" Update all changed buffers
command! -nargs=0 -bang Wall :call functions#Wall(<bang>0)

" Custom one-sided folder markers
command! -nargs=1 FoldMarker :set foldmethod=expr|set foldexpr=getline(v:lnum)=~'<args>'?'>1':'='

" Indent sort
command! -nargs=0 -range SortIndent :call functions#sort_indent()

" Bitbucket links
command! -range -bang Bitbucket silent exe "!bitbucket " ("<bang>" == "!" ? "--use-commit " : "") "--git-dir" expand("%:h") expand("%") "<line1>:<line2>" | redraw!
command! -range -bang Github silent exe "!github " ("<bang>" == "!" ? "--use-commit " : "") "--git-dir" expand("%:h") expand("%") "L<line1>-L<line2>" | redraw!

" Populate qflist with filename pattern
command! -nargs=+ -complete=file Cadd :call functions#cadd("git ls-files " . <q-args>)
command! -nargs=+ -complet=shellcmd CaddCmd :call functions#cadd(<q-args>)

" HightlightRepeats
command! -range=% RepeatedLines normal /\%><line1>l\%<<line2>l^\(.*\)$\n\1$/\<CR>

" Using a program with formatexpr
function! <SID>FormatBuffer()
	if &formatprg == ''
		echo "No formatting program set. Use 'formatprg'"
		return
	endif
	let l:s = winsaveview()
	silent execute '%!' . &formatprg
	call winrestview(l:s)
endfunction
command! FormatBuffer call <SID>FormatBuffer()

" Run tig
function! <SID>Tig(bang, ...)
	if a:bang > 0
		let cmd = ["tig", expand('%')]
	elseif a:0 > 0
		let cmd = ["tig"] + a:000
	else
		let cmd = ["tig", "status"]
	endif
	call functions#popup_cmd(cmd, "win", {})
endfunction
command! -bang -nargs=* Tig call <SID>Tig(<bang>0, <f-args>)

" View a diff of the current file
function! <SID>Diff()
	let filename = expand('%')
	let tempfile = tempname()
	execute "write " . tempfile

	let cmd = "diff -u --color=always " . tempfile . " '" . filename . "' | less -SR +g"
	call functions#popup_cmd(cmd, "editor", {})
endfunction
command! -nargs=0 Diff call <SID>Diff()

" View a git diff of the current file
function! <SID>GitDiff(...)
	let cmd = "git diff --color " . expand('%') . " | less -SR +g"
	call functions#popup_cmd(cmd, "editor", {})
endfunction
command! -nargs=* GitDiff call <SID>GitDiff()

" Highlight git merge conflicts
function! ConflictsHighlight() abort
	syn match conflictStart /^<<<<<<< .*$/
	syn match conflictMiddle1 /^||||||| .*$/
	syn match conflictMiddle2 /^=======$/
	syn match conflictEnd /^>>>>>>> .*$/

	highlight link conflictStart DiffDelete
	highlight link conflictMiddle1 DiffChange
	highlight link conflictMiddle2 DiffChange
	highlight link conflictEnd DiffAdd
endfunction

augroup highlight_git_conflict_markers
	autocmd!
	autocmd BufEnter * call ConflictsHighlight()
augroup END

" Change buffer directory to the root of the current git directory
function! <SID>RepoRoot()
	let root = system(["git", "rev-parse", "--show-toplevel"])
	if v:shell_error
		echohl WarningMsg
		echo "Could not find git repository root"
		echohl None
		return
	endif
	exe 'lcd' root
	pwd
endfunction
command! -nargs=0 RepoRoot call <SID>RepoRoot()

" Base64 decode highlighted text
function! <SID>Base64Decode() range
	let l:paste = &paste
	set paste
	normal! gv
	execute "normal! c\<c-r>=system(\"base64 --decode\", @\")\<cr>\<esc>"
	normal! `[v`]h
	let &paste = l:paste
endfunction
command! -nargs=0 -range Base64Decode call <SID>Base64Decode()
