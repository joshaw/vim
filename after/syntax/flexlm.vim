" Created:  Tue 24 Mar 2015
" Modified: Fri 20 Nov 2015
" Author:   Josh Wainwright
" Filename: flexlm.vim

" For version 6.x: Quit when a syntax file was already loaded
if exists('b:current_syntax')
  finish
endif

" Syntax is case INsensitive
syn case ignore

syn keyword flexlmStatement SERVER DAEMON USE_SERVER VENDOR

syn keyword flexlmStatement FEATURE INCREMENT PACKAGE skipwhite nextgroup=flexlmToken
syn region  flexlmToken     start="\S" end="\s" skipwhite nextgroup=flexlmDaemon
syn region  flexlmDaemon    start="\S" end="\s" skipwhite nextgroup=flexlmVer
syn region  flexlmVer       start="\S" end="\s" skipwhite nextgroup=flexlmDate,flexlmComps,flexlmStuff
syn region  flexlmDate      start="\S" end="\s" skipwhite nextgroup=flexlmCount,flexlmComps,flexlmStuff
syn region  flexlmCount     start="\S" end="\s" skipwhite nextgroup=flexlmStuff,flexlmComps,flexlmStuff
syn keyword flexlmComps     COMPONENTS nextgroup=flexlmStuff
syn region  flexlmStuff     start="\S" end="$" contains=flexlmComponent,flexlmOption
syn match   flexlmComponent "\v(\s|\")\zs\S*:"
syn match   flexlmOption    "\v\s\S*\="

syn region  flexlmComment   start=/#/ end=/$/

syn sync minlines=10

command -nargs=+ HiLink hi def link <args>

HiLink flexlmComment   Comment
HiLink flexlmStatement Keyword
HiLink flexlmToken     Identifier
HiLink flexlmDaemon    Tag
HiLink flexlmVer       Label
HiLink flexlmCount     Macro
HiLink flexlmStuff     Type
HiLink flexlmComps     Boolean
HiLink flexlmComponent Include
HiLink flexlmOption    Boolean

delcommand HiLink

let b:current_syntax = 'flexlm'
