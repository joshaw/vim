" Created:  Mon 02 Nov 2015
" Modified: Fri 05 Feb 2016
" Author:   Josh Wainwright
" Filename: vimp.vim

augroup vimp
	au!
	autocmd BufReadCmd *.gpg :call vimp#decrypt(expand('<afile>'))
	autocmd BufWriteCmd *.gpg :call vimp#encrypt(expand('<afile>'))

	autocmd BufEnter pass.gpg :setf mypass.conf
				\ | setlocal conceallevel=2 concealcursor=nc
				\ | syntax region hideup Conceal start='|' end='$'
				\ | setlocal colorcolumn=0
				\ | call cursor(1,1) | /^$
augroup END
