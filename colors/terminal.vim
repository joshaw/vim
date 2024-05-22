set notermguicolors

let g:colors_name = "terminal"

hi Normal ctermfg=NONE ctermbg=NONE cterm=NONE
hi NormalFloat ctermfg=NONE ctermbg=black cterm=NONE
"hi link NormalFloat Normal

" Chrome
hi ColorColumn ctermfg=NONE ctermbg=black cterm=NONE
hi CursorColumn ctermfg=NONE ctermbg=black cterm=NONE
hi CursorLine ctermfg=NONE ctermbg=black cterm=NONE
hi CursorLineNr ctermfg=darkyellow ctermbg=NONE cterm=bold
hi EndOfBuffer ctermfg=black ctermbg=NONE cterm=NONE
hi ErrorMsg ctermfg=black ctermbg=darkred cterm=bold
hi FoldColumn ctermfg=grey ctermbg=NONE cterm=bold
hi Folded ctermfg=grey ctermbg=NONE cterm=italic
hi LineNr ctermfg=darkgrey ctermbg=NONE cterm=italic
hi LineNrAbove ctermfg=darkgrey ctermbg=NONE cterm=bold
hi LineNrBelow ctermfg=darkgrey ctermbg=NONE cterm=bold
hi ModeMsg ctermfg=darkgrey ctermbg=NONE cterm=NONE
hi MoreMsg ctermfg=darkgrey ctermbg=NONE cterm=NONE
hi Pmenu ctermfg=NONE ctermbg=black cterm=NONE
hi PmenuSbar ctermfg=NONE ctermbg=black cterm=NONE
hi PmenuSel ctermfg=NONE ctermbg=NONE cterm=reverse
hi PmenuThumb ctermfg=NONE ctermbg=NONE cterm=reverse
hi SignColumn ctermfg=NONE ctermbg=NONE cterm=NONE
hi Statusline ctermfg=white ctermbg=black cterm=NONE
hi StatuslineNC ctermfg=darkgrey ctermbg=black cterm=NONE
hi TabLine ctermfg=NONE ctermbg=black cterm=NONE
hi TabLineFill ctermfg=black ctermbg=NONE cterm=NONE
hi TabLineSel ctermfg=black ctermbg=grey cterm=bold
hi Title ctermfg=cyan ctermbg=NONE cterm=bold
hi WarningMsg ctermfg=darkred ctermbg=NONE cterm=NONE
hi WildMenu ctermfg=black ctermbg=darkyellow cterm=NONE
hi WinSeparator ctermfg=black ctermbg=NONE cterm=NONE
hi link VertSplit WinSeparator

" Virtual Text
hi Conceal ctermfg=grey ctermbg=NONE cterm=NONE
hi MatchParen ctermfg=darkcyan ctermbg=black cterm=reverse
hi Search ctermfg=black ctermbg=magenta cterm=underline,italic
hi Visual ctermfg=black ctermbg=darkcyan cterm=NONE
hi VisualNOS ctermfg=NONE ctermbg=NONE cterm=reverse
hi Whitespace ctermfg=darkgrey ctermbg=NONE cterm=NONE
hi link CurSearch Search
hi link IncSearch Search

" Text
hi Character ctermfg=yellow ctermbg=NONE cterm=NONE
hi Comment ctermfg=darkgrey ctermbg=NONE cterm=italic,bold
hi Constant ctermfg=yellow ctermbg=NONE cterm=bold
hi Debug ctermfg=darkcyan ctermbg=NONE cterm=NONE
hi Delimiter ctermfg=darkcyan ctermbg=NONE cterm=NONE
hi Directory ctermfg=darkcyan ctermbg=NONE cterm=bold
hi Error ctermfg=white ctermbg=darkred cterm=bold
hi Function ctermfg=blue ctermbg=None cterm=bold
hi Identifier ctermfg=blue ctermbg=NONE cterm=NONE
hi Ignore ctermfg=NONE ctermbg=NONE cterm=NONE
hi NonText ctermfg=grey ctermbg=NONE cterm=bold
hi Number ctermfg=darkmagenta ctermbg=NONE cterm=NONE
hi PreProc ctermfg=darkyellow ctermbg=NONE cterm=NONE
hi Question ctermfg=darkyellow ctermbg=NONE cterm=NONE
hi Special ctermfg=darkcyan ctermbg=NONE cterm=NONE
hi SpecialKey ctermfg=black ctermbg=grey cterm=bold
hi SpellBad ctermfg=NONE ctermbg=NONE cterm=undercurl guisp=red
hi SpellCap ctermfg=NONE ctermbg=NONE cterm=undercurl guisp=blue
hi SpellLocal ctermfg=NONE ctermbg=NONE cterm=undercurl guisp=green
hi SpellRare ctermfg=NONE ctermbg=NONE cterm=undercurl guisp=magenta
hi Statement ctermfg=darkmagenta ctermbg=NONE cterm=NONE
hi String ctermfg=yellow ctermbg=NONE cterm=NONE
hi Todo ctermfg=darkyellow ctermbg=NONE cterm=reverse
hi Type ctermfg=blue ctermbg=NONE cterm=NONE
hi Underlined ctermfg=NONE ctermbg=NONE cterm=underline
hi link Boolean Number
hi link Float Number

"
" Plugins
"

" Diff
hi DiffAdd ctermfg=darkgreen ctermbg=black cterm=NONE
hi DiffChange ctermfg=cyan ctermbg=black cterm=NONE
hi DiffDelete ctermfg=darkred ctermbg=NONE cterm=NONE
hi DiffText ctermfg=darkyellow ctermbg=black cterm=NONE

hi diffAdded ctermfg=darkgreen ctermbg=NONE cterm=NONE
hi diffChanged ctermfg=darkyellow ctermbg=NONE cterm=NONE
hi diffRemoved ctermfg=darkred ctermbg=NONE cterm=NONE
hi diffSubname ctermfg=darkmagenta ctermbg=NONE cterm=NONE

hi DiffConflictBegin ctermfg=red ctermbg=black cterm=NONE
hi DiffConflictCommonAncestors ctermfg=cyan ctermbg=black cterm=NONE
hi DiffConflictSeparator ctermfg=cyan ctermbg=black cterm=NONE
hi DiffConflictEnd ctermfg=green ctermbg=black cterm=NONE

" Quickfix
hi QuickFixLine ctermfg=NONE ctermbg=black cterm=bold,italic
hi link qfFileName Directory
hi link qfLineNr Number
"hi link qfSeparator

" GitGutter
hi link GitGutterAdd diffAdded
hi link GitGutterChange diffChanged
hi link GitGutterDelete diffSubname
hi link GitGutterChangeDelete diffRemoved
