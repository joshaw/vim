" Created:  Tue 31 Mar 2020
" Modified: Tue 23 Jun 2020
" Author:   Josh Wainwright
" Filename: jenkins.vim

if filereadable($HOME . "/bin/jenkins-lint")
	setlocal makeprg=sh\ ~/bin/jenkins-lint\ %
	setlocal errorformat=WorkflowScript:\ %l:\ %m
	setlocal errorformat+=WorkflowScript:\ [0-9]\+:\ %m\ @\ line\ %l,\ column\ %c.
	setlocal errorformat+=%-GErrors\ encountered\ validating\ Jenkinsfile:
	setlocal errorformat+=%-GJenkinsfile\ successfully\ validated.
endif
