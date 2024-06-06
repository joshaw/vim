#!/bin/sh
set -eu

fzf() {
	command fzf \
		--info=hidden \
		--preview-window="~1,+{2}/2,right,40%,border-left,<50(down,40%,border-top)" \
		--bind "ctrl-s:toggle-sort" \
		"$@"
}

fuzzy_grep() {
	git grep -nI --untracked '' \
	| fzf \
		--tiebreak=index \
		--query="$*" \
		--nth=3.. \
		--delimiter=: \
		--preview="printf '\x1b[34m%s\x1b[0m\n' {1}; sed '{2}s/^/\x1b[7m/; {2}s/$/ \x1b[0m/' {1}" \
	| awk -F: '{printf "edit +%i %s", $2, $1}'
}

cat_with_title() {
	printf '\033[34m%s\033[0m\n' "$1"
	[ -f "$1" ] && cat "$1" || printf '\033[30mFile deleted\033[0m\n'
}

fzopen_load_git() {
	git ls-files -t -z --others --modified --deleted \
	| sed -z \
		-e 's/^R /\x1b[31m/' \
		-e 's/^C /\x1b[33m/' \
		-e 's/^? /\x1b[34m/' \
		-e 's/$/\x1b[0m/'
}

fzopen_load_orig() {
	fzopen_load_git
	git ls-files -z --cached
}

fzopen_preview_git() {
	if git ls-files --error-unmatch "$1" > /dev/null 2>&1; then
		git diff --color=always -- "$1"
	else
		git diff --color=always --no-index /dev/null -- "$1"
	fi
}

fuzzy_open() {
	fzopen_load_orig \
	| fzf \
		--read0 \
		--ansi \
		--tiebreak=index \
		--scheme=path \
		--query="$*" \
		--bind="ctrl-g:change-preview(sh $0 fzopen_preview_git {})+reload(sh $0 fzopen_load_git)" \
		--bind="ctrl-f:change-preview(sh $0 cat_with_title {})+reload(sh $0 fzopen_load_orig)" \
		--preview="sh $0 cat_with_title {}" \
	| awk '{gsub(/ /, "\\ ", $0); printf "edit %s", $0}'
}

fuzzy_tag() {
	grep -v '^!_TAG_' tags \
	| grep "$*" \
	| fzf \
		--nth=1 \
		--delimiter='\t' \
		--preview="printf '\x1b[34m%s\x1b[0m\n' {2}; cat {2}" \
	| awk '{printf "tag %s", $1}'
}

"$@"
