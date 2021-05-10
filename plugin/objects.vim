" Created:  Mon 26 Oct 2015
" Modified: Mon 15 Feb 2021
" Author:   Josh Wainwright
" Filename: objects.vim

" Line object
xnoremap il :<c-u>normal! ^vg_<cr>
xnoremap al :<c-u>normal! 0v$<cr>
onoremap il :normal vil<cr>
onoremap al :normal val<cr>

" Whole file object
xnoremap if :<c-u>keepjumps normal! gg0VG<cr>
xnoremap af :<c-u>keepjumps normal! gg0VG<cr>
onoremap if :keepjumps normal vif<cr>
onoremap af :keepjumps normal vaf<cr>

" Indent object
onoremap <silent>ai :<C-U>call indent#IndTxtObj(0)<CR>
onoremap <silent>ii :<C-U>call indent#IndTxtObj(1)<CR>
vnoremap <silent>ai :<C-U>call indent#IndTxtObj(0)<CR><Esc>gv
vnoremap <silent>ii :<C-U>call indent#IndTxtObj(1)<CR><Esc>gv

" custom text-objects
for char in [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '%', '`' ]
    execute 'xnoremap i' . char . ' :<C-u>normal! T' . char . 'vt' . char . '<CR>'
    execute 'onoremap i' . char . ' :normal vi' . char . '<CR>'
    execute 'xnoremap a' . char . ' :<C-u>normal! F' . char . 'vf' . char . '<CR>'
    execute 'onoremap a' . char . ' :normal va' . char . '<CR>'
endfor
