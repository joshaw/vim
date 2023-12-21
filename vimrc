" Created:  Tue 12 Aug 2014
" Modified: Fri 17 Nov 2023
" Author:   Josh Wainwright
" Filename: vimrc

" Paths and Variables
"

let g:vimhome = '~/.vim/'
let $VIMHOME = '~/.vim/'
if has('win32')
	let g:vimhome = $HOME.'/vimfiles/'
	let $VIMHOME = $HOME.'/vimfiles/'
	let $PATH=$PATH.';C:/cygwin/bin/;'.$HOME.'/Tools/'
endif

" Plugin Settings
"

"""" Builtin Plugins
let loaded_getscriptPlugin    = 1
let loaded_gzip               = 1
let loaded_logipat            = 1
let loaded_matchparen         = 1
let loaded_netrwPlugin        = 1
let loaded_rrhelper           = 1
let loaded_spellfile_plugin   = 1
let loaded_tarPlugin          = 1
let loaded_2html_plugin       = 1
let loaded_vimballPlugin      = 1
let loaded_zipPlugin          = 1
let skip_loading_mswin        = 1
let did_install_default_menus = 1
let skip_loading_mswin = 1
let g:loaded_ruby_provider    = 0
let g:loaded_node_provider    = 0
let g:load_black = 1
let g:loaded_fzf = 1
let g:loaded_redact_pass = 1

" Settings
"

filetype plugin on
filetype indent on
syntax on
let g:vim_monokai_tasty_italic=1
colorscheme terminal

" 2 moving around, searching and patterns
set whichwrap=b,s,h,l,<,>,[,]
set nostartofline
set path=.,**
set smartcase
set ignorecase
set wildignorecase
set fileignorecase

" 4 displaying text
augroup Scrolloff
	autocmd TermOpen,TermEnter * setlocal scrolloff=0
	autocmd TermLeave * setlocal scrolloff=5
augroup END

set linebreak
set breakindent
set breakindentopt=min:10,shift:2,sbr
set display=lastline,uhex
set fillchars=vert:│
set list
set listchars=tab:·\ ,trail:▸,nbsp:_,extends:»,precedes:«
augroup vimrc_trailing
	au!
	au InsertEnter * :set listchars-=trail:▸
	au InsertLeave * :set listchars+=trail:▸
augroup END
set number

" 5 syntax, highlighting and spelling
set spell
set spelloptions+=camel
set colorcolumn=+1

" 6 multiple windows
set splitbelow
set splitright

" 9 using the mouse
set mouse=a

"12 messages and info
set shortmess=aoOstTI
silent! set shortmess+=c
set noruler
set rulerformat=%30(%=%m\ %f\ %p%%\ %l/%L\ %c%V%)
set statusline=%f\ %m%=%p%%\ %l/%L\ %c%V

"14 editing text
set textwidth=79
set formatoptions=tcrqlnj
set infercase
set showmatch
set complete-=t
set completeopt-=preview
set nrformats=alpha,bin,hex,unsigned

"15 tabs and indenting
set tabstop=4
set shiftwidth=4
set shiftround
set smartindent
set copyindent

"16 folding
set foldminlines=0
set foldmethod=marker

"20 the swap file
exe 'set directory='.g:vimhome.'/tmp/directory//'
set noswapfile

"21 command line editing
set undofile
exe 'set undodir='.g:vimhome.'/tmp/undo//'

"22 executing external commands
set grepprg=git\ grep\ --untracked\ --line-number\ --column\ $*
set grepformat=%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f\ \ %l%m

"25 language specific
set isfname-==

"27 various
set clipboard=
set virtualedit=block
if !has('nvim')
	set viminfo=!,'2000,<50,s10,h
endif

" go to last cursor position when opening files
func! s:restore_cursor() abort
	if &filetype ==# "gitcommit"
		return
	endif
	if line("'\"") > 0 && line("'\"") <= line("$")
		exe "normal! g'\""
	endif
endfunc

augroup vimrc_line_return
	au!
	autocmd BufReadPost * :call <SID>restore_cursor()
augroup END

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
