" Created:  Wed 22 Apr 2020
" Modified: Tue 28 Apr 2020
" Author:   Josh Wainwright
" Filename: indent.vim

function! indent#IndTxtObj(inner)
	if getline(".") =~ "^\\s*$"
		return
	endif

	let curline = line(".")
	let i = indent(line(".")) - &shiftwidth * (v:count1 - 1)
	let i = i < 0 ? 0 : i

	let p = line(".") - 1
	let nextblank = getline(p) =~ "^\\s*$"
	while p > 0 && (nextblank || indent(p) >= i )
		-
		let p = line(".") - 1
		let nextblank = getline(p) =~ "^\\s*$"
	endwhile

	if (!a:inner)
		-
	endif
	normal! 0V

	call cursor(curline, 0)

	let lastline = line("$")
	let p = line(".") + 1
	let nextblank = getline(p) =~ "^\\s*$"
	while p <= lastline && (nextblank || indent(p) >= i )
		+
		let p = line(".") + 1
		let nextblank = getline(p) =~ "^\\s*$"
	endwhile

	if (!a:inner)
		+
	endif

	while getline(".") =~ "^\\s*$"
		-
	endwhile
	normal! $
endfunction
