
#--------------------------------------------------------------------#
# History Words Suggestion Strategy                                  #
#--------------------------------------------------------------------#
# Suggests the most recent history word that matches the given
# prefix.
#

_zsh_autosuggest_strategy_historywords() {
	# Reset options to defaults and enable LOCAL_OPTIONS
	emulate -L zsh

	# Enable globbing flags so that we can use (#m)
	setopt EXTENDED_GLOB

	local last_word="${${=1}[-1]}"

	# Escape backslashes and all of the glob operators so we can use
	# this string as a pattern to search the $history associative array.
	# - (#m) globbing flag enables setting references for match data
	# TODO: Use (b) flag when we can drop support for zsh older than v5.0.8
	local prefix="${last_word//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"

	# Get the first history word that matches. Concatenate it together with the
	# prefix to form the full suggestion.
	# - (r) subscript flag makes the pattern match on values
	typeset -g suggestion="${1:0:-$#last_word}${historywords[(r)${prefix}?*]}"
}
