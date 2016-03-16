" Created:  Sat 12 Mar 2016
" Modified: Wed 16 Mar 2016
" Author:   Josh Wainwright
" Filename: navd.vim

#include "../autoload/navd.vim"
source ../plugin/navd.vim
source ../autoload/scratch.vim
source ../plugin/scratch.vim

call delete('tmp/navd', 'rf')
call mkdir('tmp/navd/a', 'p')
call mkdir('tmp/navd/a/d', 'p')
call mkdir('tmp/navd/a/e', 'p')
call mkdir('tmp/navd/b', 'p')
call mkdir('tmp/navd/c', 'p')
call mkdir('tmp/navd/.h', 'p')
call writefile([1,2,3,4], 'tmp/navd/a/1.t')
call writefile([1,2,3,4], 'tmp/navd/.h/1.t')
call writefile([1,2,3,4], 'tmp/navd/.h/.h.t')
call writefile([1,2,3,4], 'tmp/navd/.h.t')
call writefile([1,2,3,4], 'tmp/navd/1.t')

let expected = ['tmp/navd/a/', 'tmp/navd/b/', 'tmp/navd/c/', 'tmp/navd/1.t']
call assert_equal(s:get_paths('tmp/navd/', 0), expected)

let expected = ['tmp/navd/.h/', 'tmp/navd/a/', 'tmp/navd/b/', 'tmp/navd/c/',
			\ 'tmp/navd/.h.t', 'tmp/navd/1.t']
call assert_equal(s:get_paths('tmp/navd/', 1), expected)

let expected = ['tmp/navd/a/d/', 'tmp/navd/a/e/', 'tmp/navd/a/1.t']
call assert_equal(s:get_paths('tmp/navd/a/', 0), expected)

let expected = ['tmp/navd/.h/.h.t', 'tmp/navd/.h/1.t']
call assert_equal(s:get_paths('tmp/navd/.h/', 1), expected)

Navd tmp/navd/
let expected = ['tmp/navd/', 'tmp/navd/a/', 'tmp/navd/b/', 'tmp/navd/c/',
			\ 'tmp/navd/1.t']
call assert_equal(getline(1, '$'), expected)

Navd! tmp/navd/
let expected = ['tmp/navd/', 'tmp/navd/.h/', 'tmp/navd/a/', 'tmp/navd/b/',
			\ 'tmp/navd/c/', 'tmp/navd/.h.t', 'tmp/navd/1.t']
call assert_equal(getline(1, '$'), expected)
