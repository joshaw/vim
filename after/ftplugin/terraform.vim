" Created:  Mon 13 Jun 2022
" Modified: Thu 07 Mar 2024
" Author:   Josh Wainwright
" Filename: terraform.vim

setlocal commentstring=#\ %s

function! s:terraform_docs() abort
	let word = expand("<cWORD>")->matchstr('^\k\+(')[:-2]
	if word !=# ""
		let fmt = "https://developer.hashicorp.com/terraform/language/functions/%s"
		call system(["xdg-open", printf(fmt, word)])
		return
	endif

	" Find previous non-indented line
	let line = search('^\S', "bcnW")

	" Extract resource type, provider and resource name
	let pat = '^\(resource\|data\) "\([a-z]\+\)_\([^"]\+\)" .*$'
	let word = substitute(getline(line), pat, "\\1|\\2|\\3", "")
	if word == getline(line)
		echo "No match"
		return
	endif
	let items = split(word, "|")
	if items[0] == "data"
		let items[0] = "data-source"
	endif

	" Get argument reference
	let arg = substitute(getline("."), '^\s*\([a-z_]\+\)\s*=.*', "\\1", "")
	let anchor = ""
	if arg != getline(".")
		let anchor = "#" . arg
	endif

	echo printf("%s: %s_%s%s", items[0], items[1], items[2], anchor)
	let fmt = "https://registry.terraform.io/providers/hashicorp/%s/latest/docs/%ss/%s%s"
	call system(["xdg-open", printf(fmt, items[1], items[0], items[2], anchor)])
endfunction
command! -nargs=1 TFdocs :call s:terraform_docs()

setlocal keywordprg=:TFdocs

if executable('terraform')
	setlocal formatprg=terraform\ fmt\ -no-color\ -
	augroup terraform
		autocmd!
		autocmd BufWritePre *.tf,*.tfvars :FormatBuffer
	augroup END
endif
