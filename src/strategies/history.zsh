
#--------------------------------------------------------------------#
# History Suggestion Strategy                                        #
#--------------------------------------------------------------------#
# Suggests the history item that matches the given prefix and history
# index
#

_zsh_autosuggest_strategy_history() {
	# Reset options to defaults and enable LOCAL_OPTIONS
	emulate -L zsh

	# Enable globbing flags so that we can use (#m)
	setopt EXTENDED_GLOB

	# Extract the paramenters for this function
	typeset -g capped_history_index="${1}"
	local query="${2}"

	# Escape backslashes and all of the glob operators so we can use
	# this string as a pattern to search the $history associative array.
	# - (#m) globbing flag enables setting references for match data
	# TODO: Use (b) flag when we can drop support for zsh older than v5.0.8
	local prefix="${query//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"

	# Get the history items that match
	# - (R) subscript flag makes the pattern match on values
	# - (k) returns the entry indices instead of values
	local suggestions=(${(k)history[(R)$prefix*]})
	(( capped_history_index > $#suggestions )) && capped_history_index=${#suggestions}
	typeset -g suggestion="${history[${suggestions[${capped_history_index}]}]}"
}
