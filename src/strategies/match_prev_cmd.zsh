
#--------------------------------------------------------------------#
# Match Previous Command Suggestion Strategy                         #
#--------------------------------------------------------------------#
# Suggests the most recent history item that matches the given
# prefix, and whose preceding history item also matches the most
# recently executed command.
#
# For example, if your have just executed:
#   pwd
#   ls foo
#   ls bar
#   pwd
# And then you start typing 'ls', then the suggestion will be 'ls foo',
# rather than 'ls bar', as your most recently executed command (pwd)
# was followed by 'ls foo' on it's previous invocation.
#

_zsh_autosuggest_strategy_match_prev_cmd() {
	local prefix="$(_zsh_autosuggest_escape_command_prefix "$1")"

	# Get all history event numbers that correspond to history
	# entries that match pattern $prefix*
	local history_match_keys
	history_match_keys=(${(k)history[(R)$prefix*]})

	# By default we use the first history number (most recent history entry)
	local histkey="${history_match_keys[1]}"

	# Get the previously executed command
	local prev_cmd="$(_zsh_autosuggest_prev_command)"
	prev_cmd="$(_zsh_autosuggest_escape_command_prefix $prev_cmd)"

	# Iterate up to the first 200 history event numbers that match $prefix
	for key in "${(@)history_match_keys[1,200]}"; do
		# Stop if we ran out of history
		[[ $key -gt 1 ]] || break

		# See if the history entry preceding the suggestion matches the
		# previous command, and use it if it does
		if [[ "${history[$((key - 1))]}" == $prev_cmd ]]; then
			histkey="$key"
			break
		fi
	done

	# Echo the matched history entry
	echo -E "$history[$histkey]"
}

