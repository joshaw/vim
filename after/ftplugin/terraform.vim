" Created:  Mon 13 Jun 2022
" Modified: Tue 14 Feb 2023
" Author:   Josh Wainwright
" Filename: terraform.vim

if !executable('terraform')
	finish
endif

if executable('terraform-docs')
	setlocal keywordprg=terraform-docs
endif

setlocal commentstring=#\ %s

function! Terraform_fmt() abort
  " Save the view.
  let curw = winsaveview()

  " Make a fake change so that the undo point is right.
  normal! ix
  normal! "_x

  " Execute `terraform fmt`, redirecting stderr to a temporary file.
  let tmpfile = tempname()
  let shellredir_save = &shellredir
  let &shellredir = '>%s 2>'.tmpfile
  silent execute '%!terraform fmt -no-color -'
  let &shellredir = shellredir_save

  " If there was an error, undo any changes and show stderr.
  if v:shell_error != 0
    silent undo
    let output = readfile(tmpfile)
    echo join(output, "\n")
  endif

  " Delete the temporary file, and restore the view.
  call delete(tmpfile)
  call winrestview(curw)
endfunction

command! -nargs=0 -buffer TerraformFmt call Terraform_fmt()

augroup terraform
	autocmd!
	autocmd BufWritePre *.tf,*.tfvars :call Terraform_fmt()
augroup END
