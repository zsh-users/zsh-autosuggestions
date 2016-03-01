
#--------------------------------------------------------------------#
# Suggestion                                                         #
#--------------------------------------------------------------------#

# Get the peviously executed command (hookable for testing)
_zsh_autosuggest_prev_cmd() {
	echo -E "${history[$((HISTCMD-1))]}"
}

# Get a suggestion from history that matches a given prefix
_zsh_autosuggest_suggestion() {
	local prefix="$(_zsh_autosuggest_escape_command_prefix "$1")"

	# Get all history event numbers (reversed) that correspond to history
	# entries that match pattern $prefix*
	local history_match_keys
	history_match_keys=(${(k)history[(R)$prefix*]})

	# By default we use the first history number (most recent history entry)
	local history_key="$history_match_keys[1]"

	# If matching on the previous command is enabled ...
	if (( ${+ZSH_AUTOSUGGEST_MATCH_PREV_CMD} )); then
		# Get the previously executed command
		local prev_cmd="$(_zsh_autosuggest_prev_cmd)"
		prev_cmd="$(_zsh_autosuggest_escape_command_prefix $prev_cmd)"

		# Iterate up to the first 200 history event numbers that match $prefix
		for key in "${(@)history_match_keys[1,200]}"; do
			# Stop if we ran out of history
			[[ $key -gt 1 ]] || break

			# See if the history entry preceding the suggestion matches the
			# previous command, and use it if it does
			if [[ "${history[$((key - 1))]}" == $prev_cmd ]]; then
				history_key=$key
				break
			fi
		done
	fi

	# Echo the matched history entry
	echo -E "$history[$history_key]"
}

_zsh_autosuggest_escape_command_prefix() {
	setopt localoptions EXTENDED_GLOB

	# Escape special chars in the string (requires EXTENDED_GLOB)
	echo -E "${1//(#m)[\\()\[\]|*?]/\\$MATCH}"
}
