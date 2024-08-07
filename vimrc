" Created:  Tue 12 Aug 2014
" Modified: Tue 23 Jul 2024
" Author:   Josh Wainwright
" Filename: vimrc

" Paths and Variables
let g:vimhome = '~/.vim/'
let $VIMHOME = '~/.vim/'
if has('win32')
	let g:vimhome = $HOME.'/vimfiles/'
	let $VIMHOME = $HOME.'/vimfiles/'
	let $PATH=$PATH.';C:/cygwin/bin/;'.$HOME.'/Tools/'
endif

"""" Builtin Plugins
let did_install_default_menus = 1
let g:load_black              = 1
let g:loaded_fzf              = 1
let g:loaded_node_provider    = 0
let g:loaded_perl_provider    = 0
let g:loaded_python3_provider = 0
let g:loaded_redact_pass      = 1
let g:loaded_ruby_provider    = 0
let loaded_2html_plugin       = 1
let loaded_getscriptPlugin    = 1
let loaded_gzip               = 1
let loaded_logipat            = 1
let loaded_matchparen         = 1
let loaded_netrwPlugin        = 1
let loaded_rrhelper           = 1
let loaded_spellfile_plugin   = 1
let loaded_tarPlugin          = 1
let loaded_vimballPlugin      = 1
let loaded_zipPlugin          = 1
let skip_loading_mswin        = 1

" Settings
filetype plugin on
filetype indent on
syntax on
let g:vim_monokai_tasty_italic=1
colorscheme terminal

set breakindent
set breakindentopt=min:10,shift:2,sbr
set clipboard=
set cmdheight=1
set colorcolumn=+1
set complete-=t
set completeopt-=preview
set copyindent
set display=lastline,uhex
set fileignorecase
set foldmethod=marker
set foldminlines=0
set formatoptions=tcrqlnj
set grepformat=%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f\ \ %l%m
set grepprg=git\ grep\ --untracked\ --line-number\ --column\ $*
set ignorecase
set infercase
set isfname-==
set linebreak
set list listchars=tab:·\ ,trail:▸,nbsp:_,extends:»,precedes:«
set mouse=a
set noruler rulerformat=%30(%=%m\ %f\ %p%%\ %l/%L\ %c%V%)
set noswapfile
set nrformats=alpha,bin,hex,unsigned
set number
set path=.,**
set scrolloff=5
set shiftround
set shiftwidth=4
set shortmess=aoOstTIc
set showmatch
set smartcase
set smartindent
set spell spelloptions+=camel
set splitbelow splitright
set statusline=%f%(\ [%M%R%H%W%q]%)\ %=\ %{BufSize()}\ %l/%L:%2c\ %2p%%
set tabstop=4
set textwidth=79
set undofile
set virtualedit=block
set whichwrap=b,s,h,l,<,>,[,]
set wildignorecase

exe 'set directory='.g:vimhome.'/tmp/directory//'
exe 'set undodir='.g:vimhome.'/tmp/undo//'

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

function! BufSize()
	let size = len(join(getline(0,'$'),'x'))
	if size > 2048
		return printf('%.2fKB', size / 1024.0)
	endif
	return printf('%iB', size)
endfunction

augroup vimrc
	au!
	" Trailing whitespace indicators onlny in normal mode
	au InsertEnter * :set listchars-=trail:▸
	au InsertLeave * :set listchars+=trail:▸

	" No scrolloff in terminal windows
	autocmd TermOpen,TermEnter * setlocal scrolloff=0
	autocmd TermLeave * setlocal scrolloff=5

	" Restore cursor position
	autocmd BufReadPost * :call <SID>restore_cursor()
augroup END

" Keybindings ~/.vim/plugin/keybindings.vim
" Functions   ~/.vim/autoload/functions.vim
" Plugins     ~/.vim/plugin/plugins.vim
