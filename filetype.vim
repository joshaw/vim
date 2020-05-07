" Created:  Thu 07 Aug 2014
" Modified: Mon 02 Mar 2020
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
	FT *.tex tex
	FT *.md markdown
	FT README markdown
	FT times.txt times.conf
	FT *.mail mail
	FT *.gnu gnuplot
	FT *.dotf dot
	FT *.pp puppet
	FT Jenkinsfile* jenkins
	FT *.tf terraform
augroup END

delfunction s:FT
delcommand FT

augroup filetypesettings
	autocmd!
	"au FileType * exe 'setlocal dict+='.fnameescape($VIMRUNTIME).'/syntax/'.&filetype.'.vim'
	autocmd Filetype * exe 'setlocal dict+=$VIMHOME/spell/dicts/'.&filetype.'.dict'
augroup END
