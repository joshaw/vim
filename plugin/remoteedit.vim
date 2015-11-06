" Created:  Fri 06 Nov 2015
" Modified: Fri 06 Nov 2015
" Author:   Josh Wainwright
" Filename: remoteedit.vim

augroup remoteedit
	au!
	autocmd BufReadCmd  ssh://*,scp://*   :call remoteedit#scpedit(expand('<amatch>'), 1)
	autocmd FileReadCmd ssh://*,scp://*   :call remoteedit#scpedit(expand('<amatch>'), 0)
	autocmd BufWriteCmd ssh://*,scp://*   :call remoteedit#scpwrite(expand('<amatch>'), 0)
	autocmd FileWriteCmd ssh://*,scp://*  :call remoteedit#scpwrite(expand('<amatch>'), 1)
	autocmd FileAppendCmd ssh://*,scp://* :call remoteedit#scpwrite(expand('<amatch>'), 2)
augroup END
