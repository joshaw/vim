" Created:  Tue 15 Mar 2016
" Modified: Wed 16 Mar 2016
" Author:   Josh Wainwright
" Filename: incremental.vim

#include "../autoload/incremental.vim"
source ../plugin/keybindings.vim

let oldline = 'this is a aardvark, replace that word'
let newline = s:replace_word(oldline, 10, 'aardvark', 'sentence')
call assert_equal(newline, 'this is a sentence, replace that word')

let oldline = 'zero one two three'
let newline =  s:replace_word(oldline, 1, 'zero', 'four')
call assert_equal(newline, 'four one two three')

let oldline = 'zero one two three'
let newline =  s:replace_word(oldline, 16, 'three', 'four')
call assert_equal(newline, 'zero one two four')

let oldline = 'zero one two three'
let newline =  s:replace_word(oldline, 1, 'three', 'four')
call assert_equal(newline, 'zero one two four')

call assert_equal(s:increment_word('true', 1), 'false')
call assert_equal(s:increment_word('true', -1), 'false')
call assert_equal(s:increment_word('true', 2), 'true')
call assert_equal(s:increment_word('yes', 1), 'no')
call assert_equal(s:increment_word('in', 1), 'out')
call assert_equal(s:increment_word('mon', 2), 'wed')
call assert_equal(s:increment_word('Mon', 2), 'Wed')
call assert_equal(s:increment_word('MON', 2), 'WED')
call assert_equal(s:increment_word('monday', 2), 'wednesday')
call assert_equal(s:increment_word('Monday', 2), 'Wednesday')
call assert_equal(s:increment_word('MONDAY', 2), 'WEDNESDAY')
call assert_equal(s:increment_word('zero', 20), 'twenty')
call assert_equal(s:increment_word('zero', -20), 'one')
call assert_equal(s:increment_word('zeroth', 1), 'first')
call assert_equal(s:increment_word('jan', 1), 'feb')
call assert_equal(s:increment_word('january', 1), 'february')
call assert_equal(s:increment_word('a', 1), 'b')

silent edit tmp/incremental.t
call setline(1, 'true')
call cursor(1,1)
let newline = incremental#incremental('true', 1)
call assert_equal(getline('.'), 'false')
call assert_equal(newline, 'false')

call setline(2, 'one 2 three')
call cursor(2, 0)
call incremental#incremental(expand('<cword>'), 1)
call assert_equal(getline('.'), 'two 2 three')

call cursor(2, 5)
call incremental#incremental(expand('<cword>'), 1)
call assert_equal(getline('.'), 'two 3 three')

call setline(3, 'one 2 three')
call cursor(3, 1)
call feedkeys("\<c-a>", 'x')
call assert_equal(getline('.'), 'two 2 three')

call feedkeys("4l\<c-a>", 'x')
call assert_equal(getline('.'), 'two 3 three')

call feedkeys("\<c-x>", 'x')
call assert_equal(getline('.'), 'two 2 three')

call feedkeys("0\<c-x>", 'x')
call assert_equal(getline('.'), 'one 2 three')
