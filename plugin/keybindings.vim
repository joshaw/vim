" Created:  Mon 27 Apr 2015
" Modified: Wed 16 Nov 2016
" Author:   Josh Wainwright
" Filename: keybindings.vim

" Function Keys {{{1

map <F1> :<C-U>e ~/.dotfiles/bookmarks.md<cr>
map <F2> :<C-U>e ~/Documents/Details/times/times.txt<cr>

" Switch to display mode
nnoremap <silent> <F5> :<C-u>DisplayMode<CR>
nnoremap <silent> <F6> :<C-u>ReadingMode<CR>

" Save the current file and run the make program
map <F9>   :w <bar> make<cr><cr>
map <S-F9> :w <bar> silent make<cr>

" Print current highlight information for group under cursor
nnoremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name")
	\ . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
	\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Edit weekly reports
nnoremap <F12> :EditReport<cr>
nnoremap <S-F12> :EditReport!<cr>

inoremap <expr> <tab> functions#smart_TabComplete()
inoremap <s-tab> <c-p>

" Jump to file under cursor with cr, leader cr edits a non existing file
" Ensure quickfix and cmd windows still behave
nnoremap <cr> gf
nnoremap <F11> :call <SID>do_cmd_under_cursor()<cr>
function s:do_cmd_under_cursor()
	let line = getline('.')
	if line =~# '^vim> '
		let line = line[5:-1]
		let save_pos = winsaveview()
		silent exe line
		call winrestview(save_pos)
		echo line
	else
		echo 'Does not apply: ' . line
	endif
endfunction

nnoremap <leader><cr> :e <cfile><cr>
augroup vimrc_cr
	autocmd!
	autocmd CmdwinEnter * nnoremap <CR> <CR>
	autocmd BufReadPost quickfix nnoremap <CR> <CR>
augroup END

" Jump to start/end of file
nnoremap <s-home> gg
nnoremap <s-end> G

" Letters {{{1

" Change some options (Taken from unimpaired.vim - TPope)
nnoremap cow :set wrap!<bar>set wrap?<cr>
nnoremap col :set list!<bar>set list?<cr>
nnoremap coc :set cursorcolumn!<bar>set cursorcolumn?<cr>
nnoremap cou :set cursorline!<bar>set cursorline?<cr>
nnoremap cos :set spell!<bar>set spell?<cr>
nnoremap cop :set paste!<bar>set paste?<cr>
nnoremap com :set makeprg?<cr>

" Toggle Comment
nnoremap <silent> gcc :call functions#toggleComment()<CR>
nnoremap <silent> gc :<c-u>set opfunc=functions#toggleCommentmap<cr>g@
xnoremap <silent> gc :call functions#toggleComment()<cr>

" Align with easy align
xnoremap gl :call align#align_getchar()<cr>
nnoremap <silent> gl :<c-u>set opfunc=align#alignmap<cr>g@

" Try using jk and kj as Escape in insert mode.
inoremap jk <Esc>
inoremap kj <Esc>

" Open folds and center search result
nnoremap n nzvzz
nnoremap N Nzvzz

xnoremap u <nop>
xnoremap gu u

" Jump to end of pasted text
xnoremap <silent> y y`]
xnoremap <silent> p p`]
nnoremap <silent> p p`]

" Auto_highlight
nnoremap z/ :if autohighlight#AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>

" D and Y behave like C
nnoremap D dg_
nnoremap Y yg_

nnoremap Q :normal! n.<CR>

" Split lines, oposite of join, J
nnoremap S i<cr><esc>^mwgk:keeppatterns silent! s/\v +$//<cr>:noh<cr>`w

" Symbols {{{1

nnoremap ; :
nnoremap , ;

" Search for visually highlighted text
vnoremap * y/<C-R>"<CR>
vnoremap # y?<C-R>"<CR>

nnoremap <silent> [<space> :put! _<cr>j
nnoremap <silent> ]<space> :put _<cr>k

" Navigate buffers
nnoremap ]b :call functions#buffernext(1)<cr>
nnoremap [b :call functions#buffernext(-1)<cr>

" N/P File in dir
nnoremap ]f :call functions#nextFileInDir(1)<cr>
nnoremap [f :call functions#nextFileInDir(-1)<cr>

" Quick Fix List
nnoremap ]q :cnext<cr>
nnoremap [q :cprevious<cr>

" Surroundings
nnoremap <silent> ys :call surroundings#surroundings(0)<cr>
xnoremap <silent> S :call surroundings#surroundings(visualmode() ==# 'v'? 1: 2)<cr>

" Control Keys {{{1

" Move line up/down, maintain folds
nnoremap <silent> <C-Up>   :let fm=&fdm<bar>let &fdm='manual'<bar>move-2  <bar>let &fdm=fm<CR>
nnoremap <silent> <C-Down> :let fm=&fdm<bar>let &fdm='manual'<bar>move+   <bar>let &fdm=fm<CR>
xnoremap <silent> <C-Up>   :let fm=&fdm<bar>let &fdm='manual'<bar>move-2  <bar>let &fdm=fm<CR>gv
xnoremap <silent> <C-Down> :let fm=&fdm<bar>let &fdm='manual'<bar>move'>+ <bar>let &fdm=fm<CR>gv

" Replace selected text
xnoremap <C-r> "hy:%s/<C-r>h//g<left><left>

" Dmenu Open
if executable('dmenu')
	" map <c-t> :call DmenuOpen("tabe")<cr>
	noremap <c-f> :call dmenuOpen#DmenuOpen("e")<cr>
	noremap <c-b> :call dmenuOpen#DmenuOpen("e", 1)<cr>
endif

" Return character under cursor - works for multi-byte chars
function! s:cchar()
	return matchstr(getline('.'), '\%' . col('.') . 'c.')
endfunction

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
nnoremap <silent> g<c-a> :<c-u>call incremental#incChar(<SID>cchar(), 1)<cr>
nnoremap <silent> g<c-x> :<c-u>call incremental#incChar(<SID>cchar(), -1)<cr>

" GrepString
nnoremap <c-g> :grep<space>

" Jump to start and end of line in insert mode
inoremap <C-a> <esc>I
inoremap <C-e> <esc>A
cnoremap <c-a> <home>
cnoremap <c-e> <end>

" Switch to other splits faster
nnoremap <c-l> <c-w>l
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k

" Quick save and exit
inoremap <c-s> <c-O>:update<cr>
nnoremap <c-s> :update<cr>
nnoremap <c-Q> :q<cr>

"
" Leaders {{{1

" Insert current filename
inoremap <leader>fn <C-R>=expand("%:t")<CR>

" List all buffers and quickly switch to selected
nnoremap <leader>b :ls!<CR>:buffer<Space>

nnoremap <leader>rc :e! $MYVIMRC<CR>
nnoremap <leader>rd :e! $VIMHOME/plugin/display.vim<CR>

" Get count of word under cursor
nnoremap <leader>gc :<c-u>call functions#count()<cr>
xnoremap <leader>gc :<c-u>call functions#count()<cr>

" Fast saving
nnoremap <leader>w :w!<cr>

" System clipboard copy and paste
nmap <leader>v "+gp
imap <leader>v <esc>"+gpa
nmap <leader>ay mhggVG"+y`hzz

" Unset highlighting of a search
nnoremap <silent> <leader>q :nohlsearch<bar>diffupdate<bar>redraw!<cr>

" Shift-leftmouse searches for the word clicked on without moving
nnoremap <S-LeftMouse> <LeftMouse>:<C-U>let @/='\<'.expand("<cword>").'\>'<CR>:set hlsearch<CR>

"           Scroll Wheel = Up/Down 4 lines
"   Shift + Scroll Wheel = Up/Down 1 page
" Control + Scroll Wheel = Up/Down 1/2 page
noremap  <ScrollWheelUp>    6<C-Y>
noremap  <ScrollWheelDown>  6<C-E>
noremap  <S-ScrollWheelUp>   <C-Y>
noremap  <S-ScrollWheelDown> <C-E>
noremap  <C-ScrollWheelUp>   <C-U>
noremap  <C-ScrollWheelDown> <C-D>
inoremap <ScrollWheelUp>     <C-O>4<C-Y>
inoremap <ScrollWheelDown>   <C-O>4<C-E>
inoremap <S-ScrollWheelUp>   <C-O><C-Y>
inoremap <S-ScrollWheelDown> <C-O><C-E>
inoremap <C-ScrollWheelUp>   <C-O><C-U>
inoremap <C-ScrollWheelDown> <C-O><C-D>
map      <MiddleMouse>       <LeftMouse>
imap     <MiddleMouse>       <LeftMouse>
map      <2-MiddleMouse>     <LeftMouse>
imap     <2-MiddleMouse>     <LeftMouse>
map      <3-MiddleMouse>     <LeftMouse>
imap     <3-MiddleMouse>     <LeftMouse>
map      <4-MiddleMouse>     <LeftMouse>
imap     <4-MiddleMouse>     <LeftMouse>

" Alt Keys {{{1

if has('nvim')
	tnoremap <A-h> <C-\><C-n><C-w>h
	tnoremap <A-j> <C-\><C-n><C-w>j
	tnoremap <A-k> <C-\><C-n><C-w>k
	tnoremap <A-l> <C-\><C-n><C-w>l
	nnoremap <A-h> <C-w>h
	nnoremap <A-j> <C-w>j
	nnoremap <A-k> <C-w>k
	nnoremap <A-l> <C-w>l
endif

" Increase and decrease font size in gui using Alt-Up and Alt-Down
nnoremap <A-Up> :silent! let &guifont = substitute(
 \ &guifont,
 \ ':h\zs\d\+',
 \ '\=eval(submatch(0)+1)',
 \ '')<CR><CR>
nnoremap <A-Down> :silent! let &guifont = substitute(
 \ &guifont,
 \ ':h\zs\d\+',
 \ '\=eval(submatch(0)-1)',
 \ '')<CR><CR>
