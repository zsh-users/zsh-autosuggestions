
#--------------------------------------------------------------------#
# Start                                                              #
#--------------------------------------------------------------------#

# Start the autosuggestion widgets
_zsh_autosuggest_start() {
	add-zsh-hook -d precmd _zsh_autosuggest_start

	# Re-bind widgets on every precmd to ensure we wrap other wrappers.
	# Specifically, highlighting breaks if our widgets are wrapped by
	# zsh-syntax-highlighting widgets. This also allows modifications
	# to the widget list variables to take effect on the next precmd.
	_zsh_autosuggest_bind_autosuggest_widgets
	add-zsh-hook precmd _zsh_autosuggest_bind_autosuggest_widgets

	# If available, use a ZLE redraw hook to trigger fetching suggestions.
	# Otherwise, we need to wrap all widgets and fetch suggestions after
	# running them.
	if is-at-least 5.4; then
		add-zle-hook-widget line-pre-redraw autosuggest-redraw
	else
		_zsh_autosuggest_bind_modify_widgets
		add-zsh-hook precmd _zsh_autosuggest_bind_modify_widgets
	fi

	if [[ -n "${ZSH_AUTOSUGGEST_USE_ASYNC+x}" ]]; then
		_zsh_autosuggest_async_start
	fi
}

# Start the autosuggestion widgets on the next precmd
add-zsh-hook precmd _zsh_autosuggest_start
