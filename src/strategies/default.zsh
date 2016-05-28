
#--------------------------------------------------------------------#
# Default Suggestion Strategy                                        #
#--------------------------------------------------------------------#
# Suggests the most recent history item that matches the given
# prefix.
#

_zsh_autosuggest_strategy_default() {
	local prefix="$1"

	# Get the keys of the history items that match
	local -a histkeys
	histkeys=(${(k)history[(r)$prefix*]})

	# Echo the value of the first key
	echo -E "${history[$histkeys[1]]}"
}
