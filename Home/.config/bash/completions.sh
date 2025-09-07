# ╭─────────────────╮
# │ Tab Completions │
# ╰─────────────────╯
# https://github.com/CodesOfRishi/dotfiles
# Tab comletion for $EDITOR
editor_completion() {
	# To redraw line after fzf closes (printf '\e[5n') 
	# This is useful when the terminal is altered by FZF, and the command line gets visually corrupted or misaligned
	bind '"\e[0n": redraw-current-line' 2> /dev/null
	local selected_result 
	if selected_result="$(compgen -f -- "${COMP_WORDS[COMP_CWORD]}" | command fzf \
		--prompt='❯ ' \
		--height=~100% \
		--tiebreak=begin,index \
		--select-1 \
		--exit-0 \
		--exact \
		--layout=reverse \
		--bind=tab:down,btab:up \
		--cycle)"; then

		[[ -d "${selected_result}" ]] && selected_result="${selected_result}/" || selected_result="${selected_result} "
		COMPREPLY=( "${selected_result}" )
	fi
	printf '\e[5n'
}

complete -o nospace -F editor_completion "$EDITOR"
complete -o nospace -F editor_completion '$EDITOR'
complete -o nospace -F editor_completion nano
complete -o nospace -F editor_completion edit
