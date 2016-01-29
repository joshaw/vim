" Created:  Thu 28 Jan 2016
" Modified: Thu 28 Jan 2016
" Author:   Josh Wainwright
" Filename: ruler.vim

if ! &ruler
	finish
endif

set laststatus=0
set statusline=

let s:rl=''
let s:rl.='%40(%='
let s:rl.='%t'
let s:rl.='%m '
let s:rl.='%l/%L,%2v %3p%%'
let s:rl.='%)'

let &rulerformat=s:rl
