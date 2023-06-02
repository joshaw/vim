" Created:  Thu 20 Aug 2020
" Modified: Wed 03 May 2023
" Author:   Josh Wainwright
" Filename: json.vim

if executable('jq')
	setlocal formatprg=jq\ .
endif

function! s:json_fold_text()
	"let startline = substitute(getline(v:foldstart), "^\\s*", "\\=substitute(submatch(0), '\\s', '-', 'g')", "")
	let startline = substitute(getline(v:foldstart), "^.", "+", "")
	let endline = substitute(getline(v:foldend), "^\\s*", "", "")
	let count = v:foldend - v:foldstart
	return printf("%s %i lines %s", startline, count, endline)
endfunction
setlocal foldtext=s:json_fold_text()
setlocal foldmethod=syntax
setlocal foldlevel=999
