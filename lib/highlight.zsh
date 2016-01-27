_zsh_autosuggest_region_highlight() {
	echo "$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) $ZSH_AUTOSUGGEST_HIGHLIGHT_COLOR"
}

_zsh_autosuggest_highlight() {
	if _zsh_autosuggest_syntax_highlighting_enabled; then
		_zsh_highlight
	else
		region_highlight=("$(_zsh_autosuggest_region_highlight)")
	fi
}

#-------------------------------------------------------------------------------
# Support for zsh-syntax-highlighter
#
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
#-------------------------------------------------------------------------------

_zsh_autosuggest_syntax_highlighting_enabled() {
	[ -n "$functions[_zsh_highlight]" ]
}

_zsh_autosuggest_register_highlighter() {
	# Remove it from the list (if it exists) and re-add it
	ZSH_HIGHLIGHT_HIGHLIGHTERS=("${(@)ZSH_HIGHLIGHT_HIGHLIGHTERS:#autosuggestion}")
	ZSH_HIGHLIGHT_HIGHLIGHTERS+=(autosuggestion)
}

_zsh_highlight_autosuggestion_highlighter_predicate() {
	[ "$_ZSH_AUTOSUGGESTION_ACTIVE" = true ]
}

_zsh_highlight_autosuggestion_highlighter() {
	region_highlight+=("$(_zsh_autosuggest_region_highlight)")
}
