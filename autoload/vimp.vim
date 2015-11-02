" Created:  Mon 02 Nov 2015
" Modified: Mon 02 Nov 2015
" Author:   Josh Wainwright
" Filename: vimp.vim

function! s:check_gpg()
	if !executable('gpg') == 1
		echoerr "GPG executable has not been found"
		return 0
	endif
	return 1
endfunction

function! vimp#encrypt(file)
	if s:check_gpg()
		let pass = inputsecret('Passphrase: ')
		let rep_pass = inputsecret('Repeat passphrase: ')
		if pass ==# rep_pass
			let enc_cmd = 'gpg --quiet --yes --passphrase ' . pass .
						\ ' --symmetric --cipher-algo aes256 -o ' . a:file
			exe 'write ! ' . enc_cmd
			set nomodified
		else
			redraw
			echo "Passwords do not match. Cannot write file."
		endif
	endif
endfunction

function! vimp#decrypt(file)
	if s:check_gpg()
		let pass = inputsecret('Passphrase: ')
		let dec_cmd = 'gpg --quiet --yes --passphrase ' . pass . ' -d '
		call append(0, systemlist(dec_cmd . a:file))
		$delete _
		filetype detect
		call cursor(1,1)
	else
		exe 'edit ' . a:file
	endif
endfunction
