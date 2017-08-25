" Created:  Mon 27 Apr 2015
" Modified: Thu 27 Apr 2017
" Author:   Josh Wainwright
" Filename: weeklyr.vim

function! EndOfWeek(sep)
	let wnum = strftime('%w')
	let cur = wnum
	let tday = 5 " Friday
	if cur > tday
		let tday += 7
	endif
	while cur < tday
		let cur += 1
	endwhile
	let eow = localtime() + (86400 * (cur - wnum))
	return strftime(printf('%%Y%s%%m%s%%d', a:sep, a:sep), eow)
endfunction

function! weeklyr#EditReport(monthly, retval, ...)
	let suffix = ''
	" a:0 (number of args) is >0 if a specific date is given
	if a:0 > 0
		let date = a:1
		if a:monthly
			let suffix = 'MonthlyJAW'
		endif
	" Otherwise get the relevant current date
	else
		if a:monthly
			let date = strftime("%Y%m")
			let suffix = 'MonthlyJAW'
		else
			let date = EndOfWeek('')
		endif
	endif
	let thisweek = '$HOME/Documents/Forms/WeeklyReports/'.date.suffix
	if filereadable(expand(thisweek).'.md')
		if a:retval
			return thisweek.".md"
		else
			exec "edit ".thisweek.".md"
		endif
	elseif filereadable(expand(thisweek).'.txt')
		if a:retval
			return thisweek.".txt"
		else
			exec "edit ".thisweek.".txt"
		endif
	else
		if a:retval
			echoerr "Report file for ".thisweek." not found."
		else
			exec "edit ".thisweek . ".md | normal iWeeklyr"
		endif
	endif
endfunction
