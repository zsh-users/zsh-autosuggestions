# Buffer was modified, update suggestion
_zsh_autosuggest_widget_modify() {
	local suggestion

	zle $(_zsh_autosuggest_original_widget $WIDGET) $@

	if [ $#BUFFER -gt 0 ]; then
		suggestion=$(_zsh_autosuggest_get_suggestion $BUFFER)
	fi

	if [ -n "$suggestion" ]; then
		POSTDISPLAY=${suggestion#$BUFFER}
	else
		unset POSTDISPLAY
	fi

	_zsh_autosuggest_highlight
}

# Clear command triggered, hide the suggestion
_zsh_autosuggest_widget_clear() {
	unset POSTDISPLAY
	_zsh_autosuggest_highlight
	zle $(_zsh_autosuggest_original_widget $WIDGET) $@
}

# Suggestion accepted, add it to the buffer
_zsh_autosuggest_widget_accept() {
	if [ $CURSOR -eq $#BUFFER ]; then
		BUFFER="$BUFFER$POSTDISPLAY"
		unset POSTDISPLAY
		CURSOR=${#BUFFER}
		_zsh_autosuggest_highlight
	else
		zle $(_zsh_autosuggest_original_widget $WIDGET) $@
	fi
}

# Create the widgets
zle -N _zsh_autosuggest_widget_modify
zle -N _zsh_autosuggest_widget_clear
zle -N _zsh_autosuggest_widget_accept
