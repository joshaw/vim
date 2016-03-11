" Created:  Wed 17 Feb 2016
" Modified: Wed 02 Mar 2016
" Author:   Josh Wainwright
" Filename: zip.vim

command! -nargs=1 -complete=file Zip :call zip#zip(<q-args>)

augroup zip
	autocmd!
	autocmd BufReadCmd *.zip,*.docx,*.xlsx,*.epub call zip#zip(expand('<amatch>'))
augroup END
