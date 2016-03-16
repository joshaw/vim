" Created:  Wed 16 Mar 2016
" Modified: Wed 16 Mar 2016
" Author:   Josh Wainwright
" Filename: whitespace.vim

#include "../autoload/whitespace.vim"

silent edit tmp/whitespace.t
call append(0, ['one    ', 'two  ', 'three', '', '', ''])
call whitespace#StripTrailing(0,'$')
call assert_equal(getline(1, 2), ['one', 'two'])
call whitespace#TrimEndLines()
call assert_equal(getline(1, '$'), ['one', 'two', 'three'])
