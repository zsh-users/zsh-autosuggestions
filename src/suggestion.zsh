
#--------------------------------------------------------------------#
# Suggestion                                                         #
#--------------------------------------------------------------------#

# Get a suggestion from history that matches a given prefix
_zsh_autosuggest_suggestion() {
	local prefix="$(_zsh_autosuggest_escape_command_prefix "$1")"

	# Get all history items (reversed) that match pattern $prefix*
	local history_matches
	history_matches=(${(j:\0:s:\0:)history[(R)$prefix*]})

	# Echo the first item that matches
	echo -E "$history_matches[1]"
}

_zsh_autosuggest_escape_command_prefix() {
	setopt localoptions EXTENDED_GLOB

	# Escape special chars in the string (requires EXTENDED_GLOB)
	echo -E "${1//(#m)[\\()\[\]|*?]/\\$MATCH}"
}
