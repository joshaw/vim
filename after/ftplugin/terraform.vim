" Created:  Mon 13 Jun 2022
" Modified: Thu 01 Feb 2024
" Author:   Josh Wainwright
" Filename: terraform.vim

setlocal commentstring=#\ %s

function! s:terraform_docs(word) abort
	if a:word !~ "_"
		echo "Not a terraform resource name"
		return
	endif
	let fmt = "https://registry.terraform.io/providers/hashicorp/%s/latest/docs/resources/%s",
	let items = split(a:word, "_")
	call system(["xdg-open", printf(fmt, items[0], join(items[1:], "_"))])
endfunction
command! -nargs=1 TFdocs :call s:terraform_docs("<args>")

setlocal keywordprg=:TFdocs

if executable('terraform')
	setlocal formatprg=terraform\ fmt\ -no-color\ -
	augroup terraform
		autocmd!
		autocmd BufWritePre *.tf,*.tfvars :FormatBuffer
	augroup END
endif
