setlocal indentexpr=Terraform_indent(v:lnum)
setlocal indentkeys+=<:>,0=},0=),0=]
setlocal autoindent
setlocal shiftwidth=2
setlocal tabstop=2
setlocal softtabstop=2
setlocal expandtab

function! Terraform_indent(lnum)
	" Begining of the file starts with no indent
	print(a:lnum)
	if a:lnum == 0
		return 0
	endif

	# Normal case is the same indent as the previous indented line
	let prevlnum = prevnonblank(a:lnum - 1)
	let thisindent = indent(prevlnum)

	# If opening a new block, increase indent
	let prevline = getline(prevlnum)
	if prevline =~# '[\[{\(]\s*$'
		let thisindent += &shiftwidth
	endif

	# If closing a block, decrease indent
	let thisline = getline(a:lnum)
	if thisline =~# '^\s*[\)}\]]'
		let thisindent -= &shiftwidth
	end

	if prevline =~# '/\*'
		let thisindent += 1
	endif

	if prevline =~# '\*/'
		let thisindent -= 1
	endif

	return thisindent
endfunction
