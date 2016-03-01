
#--------------------------------------------------------------------#
# Default Suggestion Strategy                                        #
#--------------------------------------------------------------------#
# Suggests the most recent history item that matches the given
# prefix.
#

_zsh_autosuggest_strategy_default() {
	local prefix="$(_zsh_autosuggest_escape_command_prefix "$1")"

	# Get the hist number of the most recent history item that matches
	local histkey="${${(k)history[(R)$prefix*]}[1]}"

	# Echo the history entry
	echo -E "${history[$histkey]}"
}
