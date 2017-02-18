
#--------------------------------------------------------------------#
# Start                                                              #
#--------------------------------------------------------------------#

# Start the autosuggestion widgets
_zsh_autosuggest_start() {
	add-zsh-hook -d precmd _zsh_autosuggest_start

	_zsh_autosuggest_feature_detect
	_zsh_autosuggest_bind_widgets

	if [ -n "${ZSH_AUTOSUGGEST_USE_ASYNC+x}" ]; then
		_zsh_autosuggest_async_start
	fi
}

# Start the autosuggestion widgets on the next precmd
add-zsh-hook precmd _zsh_autosuggest_start
