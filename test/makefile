# Created:  Sat 12 Mar 2016
# Modified: Wed 16 Mar 2016
# Author:   Josh Wainwright
# Filename: makefile

VIM ?= vim
VIMARGS := -i NONE -U NONE --noplugin -nN --startuptime start.log
ifndef UI
VIMARGS += -Es -c':qall!'
ifeq ($(VIM),nvim)
VIMARGS += --headless
endif
endif

ASSERT_SEARCH := "assert_(equal|true|false|exception|fails)"
TOT_TESTS := 0
START_T := $(shell date +%s%N)
VIM_CMD := $(VIM) $(VIMARGS)
GCC := cpp -P

.PHONY := FORCE all setup gen_testfiles

define print_t
@printf "$1 tests run in %0.3fs\n" $$(bc -q <<< "scale=6;($3-$2)/(10^9)")
endef

all: tmp *.vim
	$(eval END_T = $(shell date +%s%N))
	$(call print_t,$(TOT_TESTS),$(START_T),$(END_T))

tmp:
	@mkdir -p tmp

%.vim: FORCE
	@rm -f output.log
	@$(GCC) -include test.vimrc $@ 2> /dev/null > $@.test
	@$(VIM_CMD) -u $@.test 2>&1
	$(eval NTESTS = $(shell grep -E $(ASSERT_SEARCH) $@ | wc -l))
	$(eval TOT_TESTS = $(shell expr $(TOT_TESTS) + $(NTESTS)))
	@printf '=> $@ : '
	@grep . output.log && printf '\n' || printf 'Passed $(NTESTS)\n'
	@rm -f $@.test

%.vim.test: %.vim
	$(GCC) -include test.vimrc $< 2> /dev/null > $@

gen_testfiles:
	@for f in *.vim; do \
	echo "$$f -> $$f.test"; \
	$(GCC) -include test.vimrc $$f 2> /dev/null > $$f.test; \
	done

clean:
	-rm -f *.test *.log
	-rm -rf tmp/

FORCE:
