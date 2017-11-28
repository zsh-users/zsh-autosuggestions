
#--------------------------------------------------------------------#
# Default Suggestion Strategy                                        #
#--------------------------------------------------------------------#
# Suggests the most recent history item that matches the given
# prefix.
#

_zsh_autosuggest_strategy_default() {
	local prefix="$1"

	# Get the history items that match
	# - (r) subscript flag makes the pattern match on values
	typeset -g suggestion="${history[(r)${(b)prefix}*]}"
}
