" Created:  Mon 14 Mar 2016
" Modified: Mon 14 Mar 2016
" Author:   Josh Wainwright
" Filename: align.vim

#include "../autoload/align.vim"

silent edit resources/align.txt
call assert_equal(s:getrange(1, 2), ['', ''])
call assert_equal(s:getrange(3, 5), ['this is', 'some text', 'to test with'])

let text = ['one, two', 'three, four', 'five, six', 'seven, eight']

let expected = ['one   , two', 'three , four', 'five  , six', 'seven , eight']
call assert_equal(s:align(text, ',', 0, 0), expected)

let expected = ['one  ,two', 'three,four', 'five ,six', 'seven,eight']
call assert_equal(s:align(text, ',', 1, 0), expected)

let expected = ['  one , two', 'three , four', ' five , six', 'seven , eight']
call assert_equal(s:align(text, ',', 0, 1), expected)

let expected = ['  one,two', 'three,four', ' five,six', 'seven,eight']
call assert_equal(s:align(text, ',', 1, 1), expected)

let text = ['one = two = three', 'four = five = six', 'seven = eight = nine']

let expected = ['one   = two   = three', 'four  = five  = six', 'seven = eight = nine']
call assert_equal(s:align(text, '=', 0, 0), expected)

let expected = ['one  =two  =three', 'four =five =six', 'seven=eight=nine']
call assert_equal(s:align(text, '=', 1, 0), expected)

let expected = ['  one=  two=three', ' four= five=six', 'seven=eight=nine']
call assert_equal(s:align(text, '=', 1, 1), expected)

call feedkeys('3Ggl2j ', 'x')
call assert_equal(s:getrange(3, 5), s:getrange(7, 9))

call feedkeys('11Ggl2j,', 'x')
call assert_equal(s:getrange(11, 13), s:getrange(15, 17))

call feedkeys('19Ggl3j|', 'x')
call assert_equal(s:getrange(19, 22), s:getrange(24, 27))

29,32Align! |
call assert_equal(s:getrange(29, 32), s:getrange(34, 37))

39,42AlignR! |
call assert_equal(s:getrange(39, 42), s:getrange(44, 47))
