" Created:  Mon 14 Mar 2016
" Modified: Mon 14 Mar 2016
" Author:   Josh Wainwright
" Filename: cal.vim

#include "../autoload/cal.vim"

call assert_false(s:isleap(1900, "GREGORIAN"))
call assert_true( s:isleap(1996, "GREGORIAN"))
call assert_true( s:isleap(2000, "GREGORIAN"))
call assert_false(s:isleap(2001, "GREGORIAN"))
call assert_true( s:isleap(2004, "GREGORIAN"))
call assert_false(s:isleap(2014, "GREGORIAN"))
call assert_false(s:isleap(3001, "GREGORIAN"))
call assert_false(s:isleap(2831, "GREGORIAN"))
call assert_true( s:isleap(2832, "GREGORIAN"))
call assert_true( s:isleap(1900, "JULIAN"))
call assert_false(s:isleap(1993, "JULIAN"))
call assert_true( s:isleap(1996, "JULIAN"))
call assert_true( s:isleap(2000, "JULIAN"))
call assert_true( s:isleap(2004, "JULIAN"))
call assert_false(s:isleap(2014, "JULIAN"))

call assert_equal(s:monthlength(2000, 0, "GREGORIAN"), 31)
call assert_equal(s:monthlength(2000, 1, "GREGORIAN"), 29)
call assert_equal(s:monthlength(2000, 2, "GREGORIAN"), 31)
call assert_equal(s:monthlength(2000, 3, "GREGORIAN"), 30)
call assert_equal(s:monthlength(2000, 4, "GREGORIAN"), 31)
call assert_equal(s:monthlength(2000, 5, "GREGORIAN"), 30)
call assert_equal(s:monthlength(2000, 6, "GREGORIAN"), 31)
call assert_equal(s:monthlength(2000, 7, "GREGORIAN"), 31)
call assert_equal(s:monthlength(2000, 8, "GREGORIAN"), 30)
call assert_equal(s:monthlength(2000, 9, "GREGORIAN"), 31)
call assert_equal(s:monthlength(2000, 10, "GREGORIAN"), 30)
call assert_equal(s:monthlength(2000, 11, "GREGORIAN"), 31)
call assert_equal(s:monthlength(2004, 1, "GREGORIAN"), 29)

call assert_equal(s:dayofweek(2000, 0, 0, "GREGORIAN"), 5)
call assert_equal(s:dayofweek(2000, 0, 0, "GREGORIAN"), 5)
call assert_equal(s:dayofweek(2000, 0, 0, "GREGORIAN"), 5)
call assert_equal(s:dayofweek(2000, 0, 0, "GREGORIAN"), 5)
call assert_equal(s:dayofweek(2000, 5, 20, "GREGORIAN"), 2)
call assert_equal(s:dayofweek(2000, 5, 5, "GREGORIAN"), 1)
call assert_equal(s:dayofweek(2000, 5, -1, "GREGORIAN"), 2)
call assert_equal(s:dayofweek(2000, 13, 0, "GREGORIAN"), 3)

call assert_equal(s:getgrid(2000, 0, 1), '                1  2 ')
call assert_equal(s:getgrid(2000, 1, 1), '    1  2  3  4  5  6 ')
call assert_equal(s:getgrid(2000, 1, 2), ' 7  8  9 10 11 12 13 ')
call assert_equal(s:getgrid(2000, 1, 3), '14 15 16 17 18 19 20 ')
call assert_equal(s:getgrid(2000, 1, 4), '21 22 23 24 25 26 27 ')
call assert_equal(s:getgrid(2000, 1, 5), '28 29                ')

let expected = [
			\ '        June         ',
			\ 'Mo Tu We Th Fr Sa Su ',
			\ '          1  2  3  4 ',
			\ ' 5  6  7  8  9 10 11 ',
			\ '12 13 14 15 16 17 18 ',
			\ '19 20 21 22 23 24 25 ',
			\ '26 27 28 29 30       ',
			\ '                     ']

call assert_equal(s:getcal(2000, 5, 0), expected)

let expected = [
			\ '       March         ',
			\ 'Mo Tu We Th Fr Sa Su ',
			\ '                   1 ',
			\ ' 2  3  4  5  6  7  8 ',
			\ ' 9 10 11 12 13 14 15 ',
			\ '16 17 18 19 20 21 22 ',
			\ '23 24 25 26 27 28 29 ',
			\ '30 31                ']

call assert_equal(s:getcal(2015, 2, 0), expected)

let expected = [
			\ '     September       ',
			\ 'Mo Tu We Th Fr Sa Su ',
			\ '    1  2 14 15 16 17 ',
			\ '18 19 20 21 22 23 24 ',
			\ '25 26 27 28 29 30    ',
			\ '                     ',
			\ '                     ',
			\ '                     ']

call assert_equal(s:getcal(1752, 8, 0), expected)
