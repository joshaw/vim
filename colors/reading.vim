" Created:  Fri 18 Dec 2015
" Modified: Thu 03 Mar 2016
" Author:   Josh Wainwright
" Filename: reading.vim

set background=light
" highlight clear
" if exists("syntax_on")
"     syntax reset
" endif

let g:colors_name = "reading"

hi! Normal guifg=#F8F8F2 guibg=#272822 guisp=#272822 gui=NONE ctermfg=230 ctermbg=235 cterm=NONE

hi! NonText guifg=bg guibg=bg ctermfg=bg ctermbg=bg
hi! link VertSplit NonText
hi! link LineNr NonText
