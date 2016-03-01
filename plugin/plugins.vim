" Created:  Sun 26 Apr 2015
" Modified: Tue 01 Mar 2016
" Author:   Josh Wainwright
" Filename: plugins.vim

" BookReformatCmd
command! BookReformatCmd call booksreformat#BookReformatCmd()

" Timestamp
augroup timestamp
	autocmd!
	autocmd! BufRead * :call timestamp#Timestamp()
augroup END

"Whitespace
command! -range=% -nargs=0 StripTrailing :call whitespace#StripTrailing(<line1>,<line2>)
command! -nargs=0 TrimEndLines :call whitespace#TrimEndLines()

" DisplayMode
command! -nargs=0 ReadingMode call display#Reading_mode_toggle()
command! -nargs=0 DisplayMode call display#Display_mode_toggle()
augroup DisplayMode
	autocmd VimEnter * call display#Display_mode_start()
augroup END

" Super Retab
command! -nargs=? -range=% Space2Tab call super_retab#IndentConvert(<line1>,<line2>,0,<q-args>)
command! -nargs=? -range=% Tab2Space call super_retab#IndentConvert(<line1>,<line2>,1,<q-args>)
command! -nargs=? -range=% RetabIndent call super_retab#IndentConvert(<line1>,<line2>,&et,<q-args>)

" Weekly Report
command! -nargs=* -bang EditReport :call weeklyr#EditReport('<bang>' == '!', 0, <f-args>)

" DiffOrig
" View the difference between the buffer and the file the last time it was saved
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis

" BufGrep
command! -nargs=1 BufGrep :call functions#BufGrep(<f-args>)

" Sum
command! -range -nargs=0 -bar Sum call functions#Sum()

" Verbose
command! -range=999998 -nargs=1 -complete=command Verbose
      \ :exe functions#Verbose(<count> == 999998 ? '' : <count>, <q-args>)

" Oldfiles
command! -nargs=0 Oldfiles :call functions#Oldfiles()

" IPtables
command! IPtablesSort :call functions#IPtablesSort()

" FirstTimeRun
command! FirstTimeRun :call functions#FirstTimeRun()

" Nroff formatting of html files
command! -nargs=? Html2Nroff :call functions#html2nroff(<args>)

" Show non-ascii characters in text
command! -nargs=0 AsciiToggle :call functions#AsciiToggle()

" Align text on character
command! -range=% -nargs=? -bang Align :<line1>,<line2>call align#align('<args>', <bang>0, 0)
command! -range=% -nargs=? -bang AlignR :<line1>,<line2>call align#align('<args>', <bang>0, 1)

" Calendar
command! -nargs=* -bang -bar Cal :call cal#cal(<bang>0, <f-args>)
command! -nargs=* -bar CalBuf :call cal#calbuf(<f-args>)
command! -nargs=0 Clock :call cal#clock()

" Langton's Ant
command! -nargs=1 -bar Langton :call langton#langton(<f-args>)


" TestFeatures
command! -nargs=0 TestFeatures :call functions#testfeatures()

" Update all changed
command! -nargs=0 Wall :let buf=bufnr('.') | bufdo update | exec 'b' buf

" Revs
command! -nargs=0 GitLog :call revs#gitLog(expand('%'))
