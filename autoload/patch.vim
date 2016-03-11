" Created:  Fri 11 Mar 2016
" Modified: Fri 11 Mar 2016
" Author:   Josh Wainwright
" Filename: patch.vim

function! patch#patch(fname, diffopts) abort
	if ! &modified
		echo "File not modified."
		return
	endif

	let tmpname = tempname()
	silent exe 'w' tmpname

	let origlabel = '--label "ORIGINAL ' . strftime('%c', getftime(a:fname)) . '"'
	let modlabel  = '--label "MODIFIED ' . strftime('%c') . '"'
	let fname = shellescape(a:fname)
	let cmd = printf('diff %s %s %s %s %s', a:diffopts, origlabel, fname, modlabel, tmpname)
	silent let patchcontents = systemlist(cmd)

	if v:shell_error == 0
		echo "No differences."
		return
	elseif v:shell_error == 2
		echoerr "Diff reported error."
		return
	endif

	enew
	call append(0, patchcontents)
	$delete _
	silent! %s/\%x0d//e
	setfiletype diff
endfunction
