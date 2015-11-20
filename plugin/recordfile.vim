" Created:  Mon 26 Oct 2015
" Modified: Fri 20 Nov 2015
" Author:   Josh Wainwright
" Filename: recordfile.vim

let s:histfile = expand('~/Documents/Details/files/files.txt')
if !filewritable(s:histfile)
	finish
endif

augroup record_files
	au!
 	autocmd VimEnter,BufAdd * :silent call <SID>recordFile(expand('<afile>'))
augroup END

function! s:recordFile(file)
	let save_vfile = &verbosefile
	set verbosefile=
	if !filereadable(a:file) || isdirectory(a:file)
		return
	endif
	let size = getfsize(a:file)
	let type = getftype(a:file)
	let time = getftime(a:file)
	let fname = fnamemodify(a:file, ':p')
	let fname = substitute(fname, escape($HOME, '\'), '~', '')
	let fname = substitute(fname, '^H:\\', '~/', '')
	let fname = substitute(fname, '^L:\\', '~/Resources', '')
	let fname = substitute(fname, '\\', '/', 'g')

	exe 'redir >>' s:histfile
		echo strftime('%Y-%m-%d %H:%M:%S') '|' fname '|' size '|' type '|' time
	redir END
	let &verbosefile = save_vfile
endfunction
