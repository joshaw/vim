" Created:  Tue 12 Aug 2014
" Modified: Fri 06 Nov 2015
" Author:   Josh Wainwright
" Filename: vimrc

" Paths and Variables            {{{1
"

let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
let g:vimhome = '~/.vim/'
let $VIMHOME = '~/.vim/'
if has('win32')
	let g:vimhome = $HOME.'/vimfiles/'
	let $VIMHOME = $HOME.'/vimfiles/'
	let $PATH=$PATH.';C:/cygwin/bin/;'.$HOME.'/Tools/'
endif

" Plugin Settings                {{{1
"

"""" Builtin Plugins
let loaded_netrwPlugin     = 1
let loaded_rrhelper        = 1
let loaded_vimballPlugin   = 1
let loaded_getscriptPlugin = 1
let loaded_logipat         = 1
let loaded_matchparen      = 1
let loaded_2html_plugin    = 1
let loaded_rrhelper        = 1
" let loaded_zipPlugin       = 1
" let loaded_tarPlugin       = 1
" let loaded_gzip            = 1
let g:skip_loading_mswin   = 1
let loaded_spellfile_plugin = 1
let did_install_default_menus = 1

" Settings                       {{{1
"

filetype plugin on
filetype indent on
syntax on
if has('nvim')
	augroup colourscheme
		au!
		au VimEnter * colorscheme molokaiV
	augroup END
else
	colorscheme molokaiV
	set encoding=utf-8 " character encoding used in Vim: "latin1", "utf-8"
endif

" 1 important {{{2

" 2 moving around, searching and patterns {{{2
set whichwrap=b,s,h,l,<,>,[,] " list of flags specifying which commands wrap to another line
set nostartofline      " many jump commands move the cursor to the first non-blank
set path=.,**          " list of directory names used for file searching
set incsearch          " show match for partly typed search command
set magic              " change the way backslashes are used in search patterns
set ignorecase         " ignore case when using a search pattern
set smartcase          " override 'ignorecase' when pattern has upper case characters

" 3 tags {{{2

" 4 displaying text {{{2
set scrolloff=5      " minimal number of columns to keep left and right of the cursor
set wrap             " margin from the right in which to break a line
set linebreak        " wrap long lines at a character in 'breakat'
set display=lastline,uhex " show lastline even if it doesn't fit
set fillchars=vert:│ " characters to use for the status line, folds and filler lines
set cmdheight=1      " number of lines used for the command-line
set lazyredraw       " don't redraw while executing macros
set list             " show <Tab> as ^I and end-of-line as $
set listchars=tab:·\ ,trail:▸,nbsp:#,extends:»,precedes:« " list of strings used for list mode
augroup vimrc_trailing " {{{
	au!
	au InsertEnter * :set listchars-=trail:▸
	au InsertLeave * :set listchars+=trail:▸
augroup END " }}}
set number                 " show the line number for each line
silent! set relativenumber " show the relative line number for each line

" 5 syntax, highlighting and spelling {{{2
set synmaxcol=200      " maximum column to look for syntax items
set hlsearch           " highlight all matches for the last used search pattern
set cursorline         " highlight the screen line of the cursor
if exists("&colorcolumn")
	set colorcolumn=+1 " columns to highlight
else
	:mat ErrorMsg '\%81v.\+'
endif

" 6 multiple windows {{{2
set laststatus=2     " 0, 1 or 2; when to use a status line for the last window
set hidden           " don't unload a buffer when no longer shown in a window
set switchbuf=usetab " "useopen" and/or "split"; which window to use when jumping
set splitbelow       " a new window is put below the current one
set splitright       " a new window is put right of the current one

" 7 multiple tab pages {{{2
" 8 terminal {{{2
set t_vb=

" 9 using the mouse {{{2
set mouse=a   " list of flags for using the mouse
set mousehide " hide the mouse pointer while typing
set ttymouse=xterm2

"10 GUI {{{2
if has('win32') || has('win32unix')
	set guifont=Consolas:h11:cANSI " list of font names to be used in the GUI
else
	set guifont=Droid\ Sans\ Mono\ 10,DeJaVu\ Sans\ Mono\ 10
	set guifont=
endif
if has("gui_running")
	" set guioptions+=P "allow visual selection to be accessed in system paste
	set guioptions+=c "use console dialogues
	set guioptions-=L "left hand toolbar isn't present
	set guioptions-=T "remove tool bar
	set guioptions-=m "remove menu bar
	set guioptions-=l "remove right scroll
	set guioptions-=r "remove left scroll
	set guioptions-=b "remove bottom scroll
endif

"11 printing {{{2

"12 messages and info {{{2
set shortmess=aoOstT  " list of flags to make messages shorter
silent! set shortmess+=c
set showcmd           " show (partial) command keys in the status line
set ruler             " show cursor position below each window
exe 'set verbosefile='.g:vimhome . 'errors.log'
set nomore            " pause listings when the screen is full
set novisualbell      " use a visual bell instead of beeping
set noerrorbells      " ring the bell for error messages

"13 selecting text {{{2

"14 editing text {{{2
set textwidth=79                     " line length above which to break a line
set wrapmargin=0                     " margin from the right in which to break a line
set backspace=indent,eol,start       " specifies what <BS>, CTRL-W, etc. can do in Insert mode
set formatoptions=tcrqln             " list of flags that tell how automatic formatting works
silent! set formatoptions+=j         " list of flags that tell how automatic formatting works
set complete=.,w,b,u,k,t             " specifies how Insert mode completion works for CTRL-N and CTRL-P
set completeopt=menu                 " whether to use a popup menu for Insert mode completion
set infercase                        " adjust case of a keyword completion match
set showmatch                        " when inserting a bracket, briefly jump to its match
set matchtime=5                      " tenth of a second to show a match for 'showmatch'
set nrformats=hex                    " number formats recognized for CTRL-A and CTRL-X commands

"15 tabs and indenting {{{2
set tabstop=4      " number of spaces a <Tab> in the text stands for
set shiftwidth=4   " number of spaces used for each step of (auto)indent
set smarttab       " a <Tab> in an indent inserts 'shiftwidth' spaces
set softtabstop=0  " if non-zero, number of spaces to insert for a <Tab>
set shiftround     " round to 'shiftwidth' for "<<" and ">>"
set noexpandtab    " expand <Tab> to spaces in Insert mode
set autoindent     " automatically set the indent of a new line
set smartindent    " do clever autoindenting
set copyindent     " copy whitespace for indenting from previous line
set preserveindent " preserve kind of whitespace when changing indent

"16 folding {{{2
set foldminlines=0        " minimum number of screen lines for a fold to be closed
set foldmethod=marker     " folding type: "manual", "indent", "expr", "marker" or "syntax"

"17 diff mode {{{2

"18 mapping {{{2
set timeoutlen=300 " time in msec for 'timeout'

"19 reading and writing files {{{2
set modeline                        " enable using settings from modelines when reading a file
set fileformats=unix,dos,mac        " list of file formats to look for when editing a file
set endofline                       " last line in the file has an end-of-line
set writebackup                     " write a backup file before overwriting a file
set backup                          " write a backup file before overwriting a file
" list of directories to put backup files in
exe 'set backupdir='.g:vimhome.'tmp/backup//'
"set autowrite                       " automatically write a file when leaving a modified buffer
set autoread                        " automatically read a file when it was modified outside of Vim

"20 the swap file {{{2
" list of directories for the swap file
exe 'set directory='.g:vimhome.'/tmp/directory//'
set noswapfile                         " use a swap file for this buffer

"21 command line editing {{{2
set history=700                 " how many command lines are remembered
set wildmode=full               " specifies how command line completion works
" set wildignore=*.o,*~,*.pyc     " ignore case when completing file names
" set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*.class
" silent! set wildignorecase      " ignore case when completing file names
set wildmenu                    " command-line completion shows a list of matches
set cmdwinheight=3              " height of the command-line window
set undofile                    " automatically save and restore undo history
" list of directories for undo files
exe 'set undodir='.g:vimhome.'/tmp/undo//'

"22 executing external commands {{{2
if has('win32')
" 	set shell=C:/cygwin/bin/bash
" 	set shellcmdflag=--login\ -c\ 'cd\ $PWD'\ -c
" 	set shellxquote=\"

	let &shell='C:/cygwin/bin/bash.exe --rcfile c:/cygwin/home/' . $USERNAME . '/.bashrc ' . '-i '
	set shellcmdflag=-c
	set shellxquote=\"
else
	set shell=sh
endif
set keywordprg="" " program used for the "K" command

"23 running make and jumping to errors {{{2
set makeprg=make\ >\ /dev/null " program used for the ":make" command

"24 system specific {{{2

"25 language specific {{{2
set isfname-==

"26 multi-byte characters {{{2

"27 various {{{2
set virtualedit+=block " when to use virtual editing: "block", "insert" and/or "all"
" set viminfo=!,'2000,<50,s10,h   " list that specifies what to write in the viminfo file
" if has('gui_running')
" 	set viminfo+=n$HOME/.win.viminfo
" else
" 	set viminfo+=n$HOME/.viminfo
" endif

" go to last cursor position when opening files
augroup vimrc_line_return
	au!
	autocmd BufReadPost *
		\ if line("'\"") > 0 && line("'\"") <= line("$") |
			\ exe "normal! g'\"" |
		\ endif
augroup END

" }}}2

" FileTypes                      {{{1
"

if has("autocmd") && exists("+omnifunc")
	augroup Vimrc
		au!
		autocmd Filetype *
					\	if &omnifunc == "" |
					\		setlocal omnifunc=syntaxcomplete#Complete |
					\	endif
	augroup END
endif

if has('win32') || has('win32unix')
	let dictfile="C:/cygwin/usr/share/dict/words"
else
	let dictfile="/usr/share/dict/words"
endif

" Abbreviations                  {{{1
"
function! s:snipfunc(name, ...)
	let repl = join(a:000, ' ')
	exe "iabbrev <buffer> ".a:name."# ".repl
endfunction

command! -nargs=+ Snip :call s:snipfunc(<f-args>)

cabbrev help vert help
cabbrev w!! w !sudo tee > /dev/null %

iabbrev <expr> dts strftime("%d/%m/%Y")
iabbrev <expr> dty strftime("%Y%m%d")
iabbrev <expr> dtyd strftime("%Y-%m-%d")
iabbrev <expr> dtl strftime("%c")

function! CreatedHeader()
	return "Created:  TIMESTAMP\<CR>"
	    \ ."Modified: TIMESTAMP\<CR>"
	    \ ."Author:   Josh Wainwright\<CR>"
	    \ ."Filename: " . expand('%:t')
endfunction

iabbrev <expr> Cre: CreatedHeader()

Snip TST TIMESTAMP
Snip Copyr Copyright: 2015, LDRA Ltd.

" LDRA                           {{{1
"

iabbrev <expr> Weeklyr "Weekly Report<CR>
                       \=============<CR>
                       \Josh Wainwright<CR>
                       \Week ending " . DateOnFri('/') . "<CR>
                       \- <CR>
                       \<CR>
                       \Customer Site Visits<CR>
                       \--------------------<CR>
                       \<CR>
                       \Vacation<CR>
                       \--------<CR>
                       \- None"

command! TBini :e C:\ProgramData\LDRA\TESTBED.ini
nnoremap <F11> :<C-U>e ~/Documents/Details/ldra-learnt.md<cr>
command! FormatWikiEntry :Tabularize /\(\( \|^\)\zs|\)\|\^

if !has('nvim') && has("gui_running") && !exists("g:vim_started")
	set lines=40
	exe "set columns=" . (82+&numberwidth)
	let g:vim_started = 1
endif
" }}}

" Keybindings
"         ~/.vim/plugin/keybindings.vim
"         ~\\vimfiles\\plugin\\keybindings.vim
" Functions
"         ~/.vim/autoload/functions.vim
"         ~\\vimfiles\\autoload\\functions.vim
" Plugins
"         ~/.vim/plugin/plugins.vim
"         ~\\vimfiles\\plugin\\plugins.vim
" vim: fdm=marker nowrap
