" Created:  Mon 13 Jun 2022
" Modified: Fri 22 Dec 2023
" Author:   Josh Wainwright
" Filename: terraform.vim

setlocal commentstring=#\ %s

if executable('terraform-docs')
	command! -nargs=1 TFdocs :echo system("terraform-docs " . expand("<cword>"))
	setlocal keywordprg=:TFdocs
endif

if executable('terraform')
	setlocal formatprg=terraform\ fmt\ -no-color\ -
	augroup terraform
		autocmd!
		autocmd BufWritePre *.tf,*.tfvars :FormatBuffer
	augroup END
endif
