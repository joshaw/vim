#!/bin/sh
set -eu

fzf() {
	command fzf \
		--info=hidden \
		--preview-window="~1,+{2}/2,right,40%,border-left,<50(down,40%,border-top)" \
		--bind pgup:preview-half-page-up \
		--bind pgdn:preview-half-page-down \
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
	[ -f "$1" ] && cat "$1"
}

fzopen_load_git() {
	git status --short --untracked-files=all \
	| sed \
		-e 's/^.D /\x1b[31m/' \
		-e 's/^.M /\x1b[33m/' \
		-e 's/^?? /\x1b[34m/' \
		-e 's/$/\x1b[0m/' \
		-e 's/^[A-Z ]. //'
}

fzopen_load_orig() {
	fzopen_load_git
	git ls-files --cached
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
		--ansi \
		--tiebreak=index \
		--scheme=path \
		--query="$*" \
		--bind="ctrl-g:change-preview(sh $0 fzopen_preview_git {})+reload(sh $0 fzopen_load_git)" \
		--bind="ctrl-f:change-preview(sh $0 cat_with_title {})+reload(sh $0 fzopen_load_orig)" \
		--preview="sh $0 cat_with_title {}" \
	| awk '{printf "edit %s", $1}'
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

CMD="$1"
shift
"$CMD" "$@"
