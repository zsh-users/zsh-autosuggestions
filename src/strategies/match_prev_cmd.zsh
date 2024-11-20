
#--------------------------------------------------------------------#
# Match Previous Command Suggestion Strategy                         #
#--------------------------------------------------------------------#
# Suggests the most recent history item that all_match the given
# prefix and whose preceding history items also all_match the most
# recently executed commands.
#
# For example, suppose your history has the following entries:
#   - pwd
#   - ls foo
#   - ls bar
#   - pwd
#
# Given the history list above, when you type 'ls', the suggestion
# will be 'ls foo' rather than 'ls bar' because your most recently
# executed command (pwd) was previously followed by 'ls foo'.
#
# You can customize how many commands have to match by setting
# `ZSH_AUTOSUGGEST_MATCH_NUM_PREV_CMDS`.
#
# Note that this strategy won't work as expected with ZSH options that don't
# preserve the history order such as `HIST_IGNORE_ALL_DUPS` or
# `HIST_EXPIRE_DUPS_FIRST`.

_zsh_autosuggest_strategy_match_prev_cmd() {
	# Reset options to defaults and enable LOCAL_OPTIONS
	emulate -L zsh

	# Enable globbing flags so that we can use (#m) and (x~y) glob operator
	setopt EXTENDED_GLOB

	# TODO: Use (b) flag when we can drop support for zsh older than v5.0.8
	local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"

	# Get the history items that match the prefix, excluding those that match
	# the ignore pattern
	local pattern="$prefix*"
	if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]; then
		pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
	fi

	# Get all history event numbers that correspond to history
	# entries that match the pattern
	local history_match_keys
	history_match_keys=(${(k)history[(R)$~pattern]})

	# By default we use the first history number (most recent history entry)
	local histkey="${history_match_keys[1]}"

	# Get the previously executed commands
	local -a prev_cmds
	local i
	for ((i = 1; i <= $ZSH_AUTOSUGGEST_MATCH_NUM_PREV_CMDS; i++)); do
		prev_cmds+="$(_zsh_autosuggest_escape_command "${history[$((HISTCMD-i))]}")"
	done

	# Iterate over the most recent history event numbers that match $prefix.
	local key all_match
	for key in "${(@)history_match_keys[1,$ZSH_AUTOSUGGEST_MATCH_PREV_MAX_CMDS]}"; do
		# Stop if we ran out of history
		[[ $key -gt 1 ]] || break

		# See if the history entries preceding the suggestion match the previous
		# commands, and use it if they do
		all_match=1
		for ((i = 1; i <= $ZSH_AUTOSUGGEST_MATCH_NUM_PREV_CMDS; i++)); do
			if [[ "${history[$((key - i))]}" != "$prev_cmds[i]" ]]; then
				all_match=0
				break
			fi
		done

		if (( all_match )); then
			histkey="$key"
			break
		fi
	done

	# Give back the matched history entry
	typeset -g suggestion="$history[$histkey]"
}
