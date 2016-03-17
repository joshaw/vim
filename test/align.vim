" Created:  Mon 14 Mar 2016
" Modified: Wed 16 Mar 2016
" Author:   Josh Wainwright
" Filename: align.vim

#include "../autoload/align.vim"
source ../plugin/plugins.vim
source ../plugin/keybindings.vim

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

silent edit resources/align.txt

normal 3Ggl2j#
call assert_equal(getline(3, 5), getline(7, 9))

normal 11Ggl2j,
call assert_equal(getline(11, 13), getline(15, 17))

normal 19Ggl3j|
call assert_equal(getline(19, 22), getline(24, 27))

29,32Align! |
call assert_equal(getline(29, 32), getline(34, 37))

39,42AlignR! |
call assert_equal(getline(39, 42), getline(44, 47))
