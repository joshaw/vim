" Created:  Thu 07 Aug 2014
" Modified: Fri 05 Feb 2016
" Author:   Josh Wainwright
" Filename: filetype.vim

if exists('did_load_filetypes')
	finish
endif

function! s:FT(pattern, filetype)
	exe 'autocmd BufRead,BufNewFile' a:pattern 'setf' a:filetype
endfunction
command! -nargs=+ FT :call s:FT(<f-args>)

augroup filetypedetect
	autocmd!
	autocmd! BufNewFile,BufRead *.dat,*.txt
				\ if search("^SERVER ", "n") > 0 && search("^VENDOR ", "n") > 0 |
				\     setfiletype flexlm |
				\ endif
	FT *.tex tex
	FT *.rout,*.Rout r
	FT *.md markdown
	FT README markdown
	FT *.bible bible
	FT three-year.txt biblereading
	FT times.txt times.conf
	" Remove spaces at the end of header lines when starting new mail in mutt.
	autocmd BufRead,BufNewFile /tmp/*/mutt* :1,/^$/s/\s\+$//
	FT *.mail mail
	FT *.tcf,*.tct tcf
	FT *vals.dat vals
	FT *tbend.dat tbend
	FT *[sS]ysearch.dat sysearch
	FT *[sS]ysppvar.dat sysppvar
	FT *[mM]etpen.dat metpen
	FT *.gnu gnuplot
	FT *.cmm practice
	FT *.dotf dot
augroup END

delfunction s:FT
delcommand FT

augroup filetypesettings
	autocmd!
	"au FileType * exe 'setlocal dict+='.fnameescape($VIMRUNTIME).'/syntax/'.&filetype.'.vim'
	autocmd Filetype * exe 'setlocal dict+=$VIMHOME/spell/dicts/'.&filetype.'.dict'
augroup END
