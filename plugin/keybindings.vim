" Created:  Mon 27 Apr 2015
" Modified: Sun 11 Jun 2023
" Author:   Josh Wainwright
" Filename: keybindings.vim

" Function Keys {{{1

" Save the current file and run the make program
map <F9>   :w <bar> make<cr><cr>
map <S-F9> :w <bar> silent make<cr>
map <F10>  magg=G`a

inoremap <expr> <tab> functions#smart_TabComplete()
inoremap <s-tab> <c-p>

vnoremap <tab> >gv
vnoremap <s-tab> <gv

" Letters {{{1

" Change some options (Taken from unimpaired.vim - TPope)
nnoremap cow :set wrap!<bar>set wrap?<cr>
nnoremap cos :set spell!<bar>set spell?<cr>

" Sort
xnoremap <silent> gs :<C-U>call functions#sort_motion(visualmode())<CR>
nnoremap <silent> gs :<C-U>set opfunc=functions#sort_motion<CR>g@

" Open
nnoremap gx :<c-u>call system("xdg-open " .. shellescape(expand("<cWORD>")))<cr>
xnoremap gx "ay:<c-u>call system("xdg-open " .. shellescape("<c-r>a"))<cr>

" Align with easy align
xnoremap gl :call align#align_getchar()<cr>
nnoremap <silent> gl :<c-u>set opfunc=align#alignmap<cr>g@

" Open folds and center search result
"nnoremap n nzvzz
"nnoremap N Nzvzz

xnoremap u <nop>
xnoremap gu u

" Jump to end of pasted text
xnoremap <silent> y y`]
xnoremap <silent> p p`]
nnoremap <silent> p p`]

nnoremap Y yg_

" Split lines, oposite of join, J
nnoremap S i<cr><esc>^mwgk:keeppatterns silent! s/\v +$//<cr>:noh<cr>`w

" Symbols {{{1

nnoremap ; :
nnoremap , ;

" Search for visually highlighted text
vnoremap * y/\V<C-R>=escape(@",'/\')<CR><CR>
vnoremap * y?\V<C-R>=escape(@",'/\')<CR><CR>

nnoremap <silent> [<space> :put! _<cr>j
nnoremap <silent> ]<space> :put _<cr>k

" Navigate buffers
nnoremap ]b :bnext<cr>
nnoremap [b :bprevious<cr>

" N/P File in dir
nnoremap ]f :call functions#nextFileInDir(1)<cr>
nnoremap [f :call functions#nextFileInDir(-1)<cr>

" Quick Fix List
nnoremap ]q :cnext<cr>zz:cc!<cr>
nnoremap [q :cprevious<cr>zz:cc!<cr>

" Quick Fix List
nnoremap ]l :lnext<cr>zz:ll!<cr>
nnoremap [l :lprevious<cr>zz:ll!<cr>

" Tabs
nnoremap ]t :tabnext<cr>
nnoremap [t :tabprevious<cr>

nnoremap - :Nnn<cr>
nnoremap _ :exe 'FGrep ' . expand("<cword>")<cr>

" Surroundings
nnoremap <silent> ys :call surroundings#surroundings(0)<cr>
xnoremap <silent> S :call surroundings#surroundings(visualmode() ==# 'v'? 1: 2)<cr>

nnoremap <space>f :FormatBuffer<cr>

" Control Keys {{{1

" Move line up/down
nnoremap <silent> <C-Up>   :move-2 <CR>
nnoremap <silent> <C-Down> :move+  <CR>
xnoremap <silent> <C-Up>   :move-2 <CR>gv
xnoremap <silent> <C-Down> :move'>+<CR>gv

nnoremap <c-g> :grep!<space><C-r><C-w>

" Dmenu Open
if executable('fzf')
	nnoremap <c-f> :FOpen<cr>
elseif executable('dmenu')
	noremap <c-f> :call dmenuOpen#DmenuOpen("e")<cr>
	noremap <c-b> :call dmenuOpen#DmenuOpen("e", 1)<cr>
endif

" Visual increment numbers
if has("patch823")
	xnoremap <c-a> <c-a>gv
	xnoremap <c-x> <c-x>gv
else
	xnoremap <c-a> :call functions#BlockIncr(1)<cr>gv
	xnoremap <c-x> :call functions#BlockIncr(-1)<cr>gv
endif
nnoremap <silent> <c-a> :<c-u>call incremental#incremental(expand('<cword>'), v:count1 * 1)<cr>
nnoremap <silent> <c-x> :<c-u>call incremental#incremental(expand('<cword>'), v:count1 * -1)<cr>

" Jump to start and end of line in insert mode
inoremap <C-a> <esc>I
inoremap <C-e> <esc>A
cnoremap <c-a> <home>
cnoremap <c-e> <end>

" Move between + resize windows
nnoremap <A-l> <C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-k> <C-w>k
nnoremap <A-j> <C-w>j

nnoremap <A-L> 4<C-w>>
nnoremap <A-H> 4<C-w><
nnoremap <A-K> <C-w>-
nnoremap <A-J> <C-w>+

" Leaders {{{1

" Unset highlighting of a search
nnoremap <silent> <leader>q :nohlsearch<bar>diffupdate<bar>redraw!<cr>
