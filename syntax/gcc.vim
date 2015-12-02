" Created:  Mon 22 Jun 2015
" Modified: Wed 25 Nov 2015
" Author:   Josh Wainwright
" Filename: gcc.vim
" syntax coloring for make output

" syn sync ccomment cMLogMess
syn sync fromstart
syn case ignore

syn match cMLogConfig "^\s\{-,4}[a-z ]\{-}:\%( \|$\)"
syn match cMLogConfig "^Set "

syn match cMLogCommand "^gcc .*$"
syn match cMLogCommand "^\%(mingw32-\)\?make .*$"

syn match cMLogCmdOpt "\[-W.\{-}\]"

syn match cMLogMissing "[\./a-zA-Z0-9_-]\+\.[a-zA-Z_]\+: No such .*$"
syn match cMLogMissing "undefined reference to .*$"

" Windows path - C:/foo/bar
syn match cMLogSource "[a-z]:[\\/][\./a-z0-9_+-]\+"
" No ext, at least 3 chars per path - foo/bar/baz
syn match cMLogSource "[\./a-z0-9_+-]\{3,}/[\./a-z0-9_+-]\{3,}"
" Start at root, at least 2 path comps - /home/user
syn match cMLogSource "/[\./a-z0-9_+-]\{3,}/[\./a-z0-9_+-]\+"
" No path, just filename with ext - source.cpp
syn match cMLogSource "[\./a-z0-9_+-]*[\/a-z0-9_+-]\.[a-z0-9]\{1,3}"
syn keyword cMLogSource makefile

syn match cMLogWarn "\<[wW]arning:.*$"
syn match cMLogErr  "error:.*$"
syn match cMLogErr  "No such .*$"
syn match cMLogErr  "`.\{-}' undeclared"
syn match cMLogErr  ".* was not built.$"
syn match cMLogErr  ".* will not be run.$"
syn match cMLogErr  ".* failed to compile .*"
syn match cMLogErr  "There were \d\+ Failures"
syn match cMLogErr  "\s*FAIL.*$"

syn keyword cMLogPass PASS

syn region cMLogMess start='^-\{3,}\s\?$' end='^-\{3,}\s\?$' contains=cMLogSource
syn region cMLogMess start='^*\{3,}\s\?$' end='^*\{3,}\s\?$' contains=cMLogSource
syn match cMLogMess "^[a-z0-9 -]* started\s\?$"
syn match cMLogMess "^[a-z0-9 -]* finished\s\?$"

syn match cMLogEnvVar "^[a-z_ ]\+\s*=\s*.*"
syn match cMLogEnvVar "%[A-Z_]\+%"

hi link cMLogConfig  Title
hi link cMLogCommand Function
hi link cMLogCmdOpt  Identifier
hi link cMLogMissing ErrorMsg
hi link cMLogSource  Special
hi link cMLogWarn    Label
hi link cMLogErr     ErrorMsg
hi link cMLogPass    Function
hi link cMLogMess    Comment
hi link cMLogEnvVar  Float
