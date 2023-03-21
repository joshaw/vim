" Created:  Wed 16 Apr 2014
" Modified: Tue 29 Nov 2022
" Author:   Josh Wainwright
" Filename: markdown.vim

"exe 'setlocal dict+='.dictfile
"setlocal keywordprg=define
"nnoremap <buffer> K :cgetexpr system('define ' . expand('<cword>'))<cr>

" Automatic formating of paragraphs whenever text is inserted
setlocal formatoptions=tcqan1
setlocal nosmartindent
setlocal tabstop=2
setlocal shiftwidth=2
setlocal expandtab

function! FormatTable()
	let w = winsaveview()

	let tabstart = search('^$', 'bW') +1
	let tabhead = tabstart + 1
	let tabend = search('^$', 'nW') -1
	exe tabhead.'d _'
	if tabstart < tabend
		exe tabstart.','.tabend.'Align |'
	else
		exe tabend.','.tabstart.'Align |'
	endif
	call append(tabstart, getline(tabstart))
	exe tabhead.'s/[^|]/-/g'

	call winrestview(w)
endfunction

" Markdown headings
nnoremap <leader>1 m`yypVr=``
nnoremap <leader>2 m`yypVr-``
nnoremap <leader>3 m`^i### <esc>``4l
nnoremap <leader>4 m`^i#### <esc>``5l
nnoremap <leader>5 m`^i##### <esc>``6l
