
#--------------------------------------------------------------------#
# Utility Functions                                                  #
#--------------------------------------------------------------------#

_zsh_autosuggest_escape_command() {
	setopt localoptions EXTENDED_GLOB

	# Escape special chars in the string (requires EXTENDED_GLOB)
	builtin echo -E "${1//(#m)[\"\'\\()\[\]|*?~]/\\$MATCH}"
}
