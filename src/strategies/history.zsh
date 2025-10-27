#--------------------------------------------------------------------#
# History Suggestion Strategy                                        #
#--------------------------------------------------------------------#
# Suggests the most recent history item that matches the given
# prefix.
#

_zsh_autosuggest_strategy_history() {
	# Reset options to defaults and enable LOCAL_OPTIONS
	emulate -L zsh

	# Enable globbing flags so that we can use (#m) and (x~y) glob operator
	setopt EXTENDED_GLOB

	local raw_prefix="$1"
	local -i offset=${2:-0}

	# Escape backslashes and all of the glob operators so we can use
	# this string as a pattern to search the history list.
	# - (#m) globbing flag enables setting references for match data
	# TODO: Use (b) flag when we can drop support for zsh older than v5.0.8
	local prefix="${raw_prefix//(#m)[\\*?\[\]<>()|^~#]/\\$MATCH}"

	# Build the matcher, excluding entries that match the ignore pattern
	local pattern="$prefix*"
	if [[ -n $ZSH_AUTOSUGGEST_HISTORY_IGNORE ]]; then
		pattern="($pattern)~($ZSH_AUTOSUGGEST_HISTORY_IGNORE)"
	fi

	local fc_output
	fc_output=$(builtin fc -ln 2>/dev/null)

	local -a matches
	matches=()

	local line
	for line in ${(f)fc_output}; do
		if [[ "$line" == ${~pattern} ]]; then
			matches=("$line" "${matches[@]}")
		fi
	done

    # no-op: keep vars local to this function to avoid global pollution

	REPLY=$#matches

	if (( offset < $#matches )); then
		typeset -g suggestion="${matches[offset+1]}"
	else
		unset suggestion
	fi
}
