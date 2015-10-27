" Created:  Mon 26 Oct 2015
" Modified: Mon 26 Oct 2015
" Author:   Josh Wainwright
" Filename: objects.vim

" Line object
xnoremap il :<c-u>normal! ^vg_<cr>
xnoremap al :<c-u>normal! 0v$<cr>
onoremap il :normal vil<cr>
onoremap al :normal val<cr>

" Whole file object
xnoremap if :<c-u>normal! gg0VG<cr>
xnoremap af :<c-u>normal! gg0VG<cr>
onoremap if :normal vif<cr>
onoremap af :normal vaf<cr>

" custom text-objects
for char in [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '%', '`' ]
    execute 'xnoremap i' . char . ' :<C-u>normal! T' . char . 'vt' . char . '<CR>'
    execute 'onoremap i' . char . ' :normal vi' . char . '<CR>'
    execute 'xnoremap a' . char . ' :<C-u>normal! F' . char . 'vf' . char . '<CR>'
    execute 'onoremap a' . char . ' :normal va' . char . '<CR>'
endfor
