" Created:  Sat 01 Aug 2015
" Modified: Fri 20 Nov 2015
" Author:   Josh Wainwright
" Filename: sysppvar.vim

if exists('b:current_syntax')
   finish
endif

" we define it here so that included files can test for it
if !exists('main_syntax')
   let main_syntax='sysppvar'
endif

syn match SysppvarNumber "\c-\?[0-9.]\+\(e\?[-+]\?\d\+\)\?[ULFD]\{,2}"
syn match SysppvarNumber "-\?0x\x\+"
syn match SysppvarNumber "-\?0x\x\+"
syn match SysppvarDefine "^\s*#\s*define\s\+"
syn match SysppvarFunction "\h\w*\s*(\@="
syn region SysppvarMacro start="^\(\s*#\s*define\s\+\)\?\S\+" end="\s" contains=SysppvarDefine
syn region SysppvarMacro start="^\(\s*#\s*define\s\+\)\?\S\+(" end=")" contains=SysppvarDefine

hi def link SysppvarNumber Number
hi def link SysppvarFunction Function
hi def link SysppvarDefine PreProc
hi def link SysppvarMacro  Macro
