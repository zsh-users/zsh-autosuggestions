
#--------------------------------------------------------------------#
# Handle Deprecated Variables/Widgets                                #
#--------------------------------------------------------------------#

_zsh_autosuggest_deprecated_warning() {
	>&2 echo "zsh-autosuggestions: $@"
}

_zsh_autosuggest_check_deprecated_config() {
	if [ -n "$AUTOSUGGESTION_HIGHLIGHT_COLOR" ]; then
		_zsh_autosuggest_deprecated_warning "AUTOSUGGESTION_HIGHLIGHT_COLOR is deprecated. Use ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE instead."
		[ -z "$ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" ] && ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=$AUTOSUGGESTION_HIGHLIGHT_STYLE
		unset AUTOSUGGESTION_HIGHLIGHT_STYLE
	fi

	if [ -n "$AUTOSUGGESTION_HIGHLIGHT_CURSOR" ]; then
		_zsh_autosuggest_deprecated_warning "AUTOSUGGESTION_HIGHLIGHT_CURSOR is deprecated."
		unset AUTOSUGGESTION_HIGHLIGHT_CURSOR
	fi

	if [ -n "$AUTOSUGGESTION_ACCEPT_RIGHT_ARROW" ]; then
		_zsh_autosuggest_deprecated_warning "AUTOSUGGESTION_ACCEPT_RIGHT_ARROW is deprecated. The right arrow now accepts the suggestion by default."
		unset AUTOSUGGESTION_ACCEPT_RIGHT_ARROW
	fi
}

_zsh_autosuggest_deprecated_start_widget() {
	_zsh_autosuggest_deprecated_warning "The autosuggest-start widget is deprecated. For more info, see the README at https://github.com/zsh-users/zsh-autosuggestions."
	zle -D autosuggest-start
	eval "zle-line-init() {
		$(echo $functions[${widgets[zle-line-init]#*:}] | sed -e 's/zle autosuggest-start//g')
	}"
}

zle -N autosuggest-start _zsh_autosuggest_deprecated_start_widget
