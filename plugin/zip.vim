" Created:  Wed 17 Feb 2016
" Modified: Tue 29 Mar 2022
" Author:   Josh Wainwright
" Filename: zip.vim

if !executable("zipinfo")
	finish
endif

command! -nargs=1 -complete=file Zip :call zip#zip(<q-args>)

augroup zip
	autocmd!
	autocmd BufReadCmd *.zip,*.docx,*.xlsx,*.epub call zip#zip(expand('<amatch>'))
augroup END
