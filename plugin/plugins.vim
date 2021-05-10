" Created:  Sun 26 Apr 2015
" Modified: Tue 30 Mar 2021
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

" DisplayMode
command! -nargs=0 ReadingMode call display#Reading_mode_toggle()
command! -nargs=0 DisplayMode call display#Display_mode_toggle()

" Super Retab
command! -nargs=? -range=% Space2Tab call super_retab#IndentConvert(<line1>,<line2>,0,<q-args>)
command! -nargs=? -range=% Tab2Space call super_retab#IndentConvert(<line1>,<line2>,1,<q-args>)
command! -nargs=? -range=% RetabIndent call super_retab#IndentConvert(<line1>,<line2>,&et,<q-args>)

" DiffOrig
" View the difference between the buffer and the file the last time it was saved
"command! Diff :w !diff --color=always --unified % - || true

" BufGrep
command! -nargs=1 BufGrep :call functions#BufGrep(<f-args>)

" Sum
command! -range -nargs=0 -bar Sum call functions#Sum()

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

" Get Patch for modifications
command! -nargs=0 Patch :call patch#patch(expand('%'), '-u')

" Custom one-sided folder markers
command! -nargs=1 FoldMarker :set foldmethod=expr|set foldexpr=getline(v:lnum)=~'<args>'?'>1':'='

" Indent sort
command! -nargs=0 -range SortIndent :call functions#sort_indent()

" Bitbucket links
command! -range -bang Bitbucket silent exe "!bitbucket " ("<bang>" == "!" ? "--use-commit " : "") "--git-dir" expand("%:h") expand("%") "<line1>:<line2>" | redraw!

" Populate qflist with filename pattern
command! -nargs=1 Cadd :call functions#cadd("git ls-files <args>")
command! -nargs=1 CaddCmd :call functions#cadd("<args>")

" HightlightRepeats
command! -range=% RepeatedLines normal /\%><line1>l\%<<line2>l^\(.*\)$\n\1$/\<CR>

" Using a program with formatexpr
function! Formatexpr_prg(cmd)
	if v:char != ''
		return
	endif
	let l:s = winsaveview()
	silent execute v:lnum . ',+' . (v:count - 1) . '!' . a:cmd
	call winrestview(l:s)
endfunction

" Run tig
function! <SID>Tig(...)
	let cmd = ["tig", "status"]
	if a:0 > 0
		let cmd = ["tig"] + a:000
	endif
	call functions#popup_cmd(cmd, "win", {})
endfunction
command! -nargs=* Tig call <SID>Tig(<f-args>)

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
