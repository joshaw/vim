" Created:  Wed 16 Apr 2014
" Modified: Sat 08 Feb 2020
" Author:   Josh Wainwright
" Filename: mail.vim

setlocal noautoindent
setlocal comments+=mb:*
setlocal comments+=n:\|
setlocal comments+=n:)
setlocal formatoptions=tcqwan21
setlocal textwidth=68
exe 'setlocal dictionary+='.dictfile
setlocal keywordprg=define
setlocal spell

if executable('par')
	setlocal formatprg=par\ -w71qie
endif

" Remove all empty lines at the end of the file, insert a single empty line and
" then insert the contents of the signature file.
nnoremap <buffer> <leader>s :%s#\($\n\s*\)\+\%$##e<cr>Go<esc>:r ~/.signature2<cr>
inoremap <buffer> <leader>s <esc>:%s#\($\n\s*\)\+\%$##e<cr>Go<esc>:r ~/.signature2<cr>``a
