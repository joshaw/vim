" Created:  Wed 16 Mar 2016
" Modified: Thu 17 Mar 2016
" Author:   Josh Wainwright
" Filename: timestamp.vim

#include "../autoload/timestamp.vim"

let expected = ['Created: ' . 'TIMESTAMP', 'Modified: ' . 'TIMESTAMP']
silent edit tmp/timestamp.t
call append(0, expected)
setlocal nomodifiable
call timestamp#Timestamp()
call assert_equal(getline(1,2), expected)

setlocal modifiable
call timestamp#Timestamp()
call assert_equal(getline(1), 'Created: ' . strftime('%a %d %b %Y'))
call assert_equal(getline(2), 'Modified: ' . strftime('%a %d %b %Y'))
call assert_false(&modified)
