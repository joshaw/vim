" Created:  Mon 14 Mar 2016
" Modified: Thu 17 Mar 2016
" Author:   Josh Wainwright
" Filename: eunuch.vim

#include "../autoload/eunuch.vim"
source ../autoload/eunuch.vim

" Remove file
call writefile([1, 2, 3, 4], 'tmp/eunuch.t')
silent edit tmp/eunuch.t
call eunuch#RemoveFile('', '')
call assert_false(filereadable('tmp/eunuch.t'))

" Remove file with modifications
call writefile([1, 2, 3, 4], 'tmp/eunuch.t')
silent edit tmp/eunuch.t
normal i123
call eunuch#RemoveFile('!', '')
call assert_false(filereadable('tmp/eunuch.t'))

" Rename file
call delete('tmp/eunuch.renamed')
call writefile([1, 2, 3, 4], 'tmp/eunuch.t')
silent edit tmp/eunuch.t
call eunuch#MoveFile('', 'tmp/eunuch.renamed')
call assert_false(filereadable('tmp/eunuch.t'))
call assert_true(filereadable('tmp/eunuch.renamed'))
call delete('tmp/eunuch.renamed')

" Move file into folder
call writefile([1, 2, 3, 4], 'tmp/eunuch.t')
call mkdir('tmp/eunuch/')
silent edit tmp/eunuch.t
call eunuch#MoveFile('', 'tmp/eunuch/eunuch.t')
call assert_false(filereadable('tmp/eunuch.t'))
call assert_true(filereadable('tmp/eunuch/eunuch.t'))
call delete('tmp/eunuch/', 'rf')

" Get maximum line length
let strings = []
for i in range(0, 10, 1)
	call add(strings, i . ' ' . repeat(i, i))
endfor
call add(strings, repeat(' ', 10) . repeat('#' , 20))
for i in range(10, 0, -1)
	call add(strings, i . ' ' . repeat(i, i))
endfor
call writefile(strings, 'tmp/eunuch.t')
silent edit tmp/eunuch.t
call assert_equal(eunuch#MaxLine(0), 12)
call assert_equal(eunuch#MaxLine(1), 11)

" Get filesize in bytes and human readable formats
call assert_equal(eunuch#FileSize(1),  229)
call assert_equal(eunuch#FileSize(0),  '229.00B')

call writefile([123], 'tmp/eunuch.t', 'b')
call assert_equal(eunuch#FileSize(1),  3)
call assert_equal(eunuch#FileSize(0),  '3.00B')

call writefile([123], 'tmp/eunuch.t')
call assert_equal(eunuch#FileSize(1),  4)
call assert_equal(eunuch#FileSize(0),  '4.00B')

call writefile([1, 2, 3], 'tmp/eunuch.t')
call assert_equal(eunuch#FileSize(1),  6)
call assert_equal(eunuch#FileSize(0),  '6.00B')

call writefile([repeat('###########################', 10000)], 'tmp/eunuch.t')
call writefile([repeat('###########################', 10000)], 'tmp/eunuch.t', 'a')
call writefile([repeat('###########################', 10000)], 'tmp/eunuch.t', 'a')
call writefile([repeat('###########################', 10000)], 'tmp/eunuch.t', 'a')
call assert_equal(eunuch#FileSize(1), 1080004)
call assert_equal(eunuch#FileSize(0), '1.03MB')

call system('dd if=/dev/zero of=tmp/eunuch.t bs=1M count=24')
call assert_equal(eunuch#FileSize(1), 25165824)
call assert_equal(eunuch#FileSize(0), '24.00MB')
call delete("tmp/eunuch.t")
