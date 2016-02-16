
#--------------------------------------------------------------------#
# Suggestion                                                         #
#--------------------------------------------------------------------#

# Get a suggestion from history that matches a given prefix
_zsh_autosuggest_suggestion() {
	setopt localoptions extendedglob

	# Escape the prefix (requires EXTENDED_GLOB)
	local prefix="${1//(#m)[\][()|\\*?#<>~^]/\\$MATCH}"

	fc -ln -m "$prefix*" 2>/dev/null | tail -1
}
