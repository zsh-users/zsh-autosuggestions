
#--------------------------------------------------------------------#
# Suggestion                                                         #
#--------------------------------------------------------------------#

# Delegate to the selected strategy to determine a suggestion
_zsh_autosuggest_suggestion() {
	local escaped_prefix="$(_zsh_autosuggest_escape_command "$1")"
	local strategy_function="_zsh_autosuggest_strategy_$ZSH_AUTOSUGGEST_STRATEGY"

	if [ -n "$functions[$strategy_function]" ]; then
		echo -E "$($strategy_function "$escaped_prefix")"
	fi
}

_zsh_autosuggest_escape_command() {
	setopt localoptions EXTENDED_GLOB

	# Escape special chars in the string (requires EXTENDED_GLOB)
	echo -E "${1//(#m)[\\()\[\]|*?~]/\\$MATCH}"
}
