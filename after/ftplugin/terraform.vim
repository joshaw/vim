" Created:  Mon 13 Jun 2022
" Modified: Thu 20 Jul 2023
" Author:   Josh Wainwright
" Filename: terraform.vim

setlocal commentstring=#\ %s

if executable('terraform-docs')
	setlocal keywordprg=terraform-docs
endif

if executable('terraform')
	setlocal formatprg=terraform\ fmt\ -no-color\ -
	augroup terraform
		autocmd!
		autocmd BufWritePre *.tf,*.tfvars :FormatBuffer
	augroup END
endif
