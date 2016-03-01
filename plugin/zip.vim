" Created:  Wed 17 Feb 2016
" Modified: Wed 17 Feb 2016
" Author:   Josh Wainwright
" Filename: zip.vim

command! -nargs=1 -complete=file Zip :call zip#zip(<q-args>)

augroup zip
	autocmd!
	autocmd BufReadCmd *.zip,*.docx,*.xlsx call zip#zip(expand('<amatch>'))
augroup END
