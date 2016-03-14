# Created:  Sat 12 Mar 2016
# Modified: Mon 14 Mar 2016
# Author:   Josh Wainwright
# Filename: makefile

TESTS = $(wildcard *.vim)
TESTFILES = $(addsuffix .test,$(TESTS))
RESULTS = $(addsuffix .out,$(TESTS))

VIM = vim -i NONE -nNes -u test.vimrc
# VIM = vim -u test.vimrc
VIMSCRIPT = 'redir >> output.log | for err in v:errors | echo err | endfor | qall!'

GCC = gcc -E -P -x c -fdirectives-only

.PHONY = all gen_testfiles

all: $(RESULTS)

%.vim.out: %.vim
	@rm -f output.log
	@$(GCC) $< | grep -v "^#" > $<.test
	@$(VIM) -S $<.test -c$(VIMSCRIPT) 2>&1
	@grep -E "^LOG:|$(PWD)/$<.test line [0-9]+: Expected" output.log || printf '=> $< : Passed\n'
	@rm -f $<.test

%.vim.test: %.vim
	$(GCC) $< | grep -v "^#" > $@

gen_testfiles: $(TESTFILES)

clean:
	-rm -f *.out *.test *.log *.tmp
	-find -type f -name "*.tmp" -delete
	-find -type d -name "*.tmpd" -delete
