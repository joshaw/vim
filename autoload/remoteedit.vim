" Created:  Fri 06 Nov 2015
" Modified: Fri 06 Nov 2015
" Author:   Josh Wainwright
" Filename: remoteedit.vim

let s:scpcmd = 'scp -p'
function! remoteedit#scpedit(path, edit)
	let filepath = shellescape(substitute(a:path, '^\(scp\|ssh\)://', '', ''))
	let tmpfile = tempname()
	call system(s:scpcmd . ' ' . filepath . ' ' . tmpfile)
	if v:shell_error
		echo "Command failed. Usage: scp://[[user@]host:]file"
		return
	endif
	exe 'read' tmpfile
	if a:edit | 0 delete _ | endif
	call delete(tmpfile)
	filetype detect
endfunction

function! remoteedit#scpwrite(path, opt)
	" opt = 0 write whole buffer
	" opt = 1 write selected text
	" opt = 2 append selected text

	let filepath = shellescape(substitute(a:path, '^\(scp\|ssh\)://', '', ''))
	let tmpfile = tempname()

	if a:opt == 0
		exe 'write' tmpfile
	elseif a:opt == 1
		exe "'[,'] write" tmpfile
	elseif a:opt == 2
		call system(s:scpcmd . ' ' . filepath . ' ' . tmpfile)
		exe "'[,'] write >>" tmpfile
	endif

	call system(s:scpcmd . ' ' . tmpfile . ' ' . filepath)
	if v:shell_error
		echo "Error: could not save file to remote location"
	else
		setlocal nomodified
	endif
	call delete(tmpfile)
endfunction