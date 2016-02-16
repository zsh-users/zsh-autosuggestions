
#--------------------------------------------------------------------#
# Suggestion                                                         #
#--------------------------------------------------------------------#

# Get a suggestion from history that matches a given prefix
_zsh_autosuggest_suggestion() {
	setopt localoptions extendedglob

	# Escape the prefix (requires EXTENDED_GLOB)
	local prefix="${1//(#m)[\][()|\\*?#<>~^]/\\$MATCH}"

	# Get all history items (reversed) that match pattern $prefix*
	local history_matches
	history_matches=(${(j:\0:s:\0:)history[(R)$prefix*]})

	# Echo the first item that matches
	echo "$history_matches[1]"
}
