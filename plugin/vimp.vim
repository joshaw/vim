" Created:  Mon 02 Nov 2015
" Modified: Mon 02 Nov 2015
" Author:   Josh Wainwright
" Filename: vimp.vim

augroup vimp
	au!
	autocmd BufReadCmd *.jgpg :call vimp#decrypt(expand('<afile>'))
	autocmd BufWriteCmd *.jgpg :call vimp#encrypt(expand('<afile>'))
	autocmd BufEnter pass.jgpg :setf mypass.conf
				\ | setlocal conceallevel=2
				\ | syntax region hideup Conceal start='|' end='$'
				\ | setlocal colorcolumn=0
				\ | call cursor(1,1) | /^$
augroup END
