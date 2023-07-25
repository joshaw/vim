" Created:  Thu 20 Jul 2023
" Modified: Thu 20 Jul 2023
" Author:   Josh Wainwright
" Filename: hcl.vim

setlocal commentstring=#\ %s

if executable('hclfmt')
	setlocal formatprg=hclfmt
	augroup hcl
		autocmd!
		autocmd BufWritePre *.hcl :FormatBuffer
	augroup END
endif
