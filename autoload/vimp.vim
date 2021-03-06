" Created:  Mon 02 Nov 2015
" Modified: Tue 08 Mar 2016
" Author:   Josh Wainwright
" Filename: vimp.vim

function! vimp#encrypt(file) abort
	if ! executable('gpg')
		echoerr 'GPG executable not found. Cannot encrypt'
		return
	endif

	let pass = inputsecret('Passphrase: ')
	if empty(pass)
		echo 'cannot be empty'
		return
	endif
	let rep_pass = inputsecret('Repeat passphrase: ')
	if pass ==# rep_pass
		let enc_cmd = 'gpg --quiet --yes --passphrase ' . pass .
					\ ' --symmetric --cipher-algo aes256 -o ' . a:file
		exe 'write ! ' . enc_cmd
		set nomodified
	else
		redraw
		echoerr 'Passwords do not match. Cannot write file.'
	endif
	unlet! pass rep_pass
endfunction

function! vimp#decrypt(file) abort
	if executable('gpg')
		let pass = inputsecret('Passphrase: ')
		let dec_cmd = 'gpg --quiet --yes --passphrase ' . pass . ' -d '
		call append(0, systemlist(dec_cmd . a:file))
		$delete _
		filetype detect
		call cursor(1,1)
	else
		echoerr 'GPG executable not found. Cannot decrypt'
		exe 'edit ' . a:file
	endif
endfunction
