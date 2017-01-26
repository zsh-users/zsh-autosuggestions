
#--------------------------------------------------------------------#
# Start                                                              #
#--------------------------------------------------------------------#

# Start the autosuggestion widgets
_zsh_autosuggest_start() {
	add-zsh-hook -d precmd _zsh_autosuggest_start

	_zsh_autosuggest_feature_detect
	_zsh_autosuggest_check_deprecated_config
	_zsh_autosuggest_bind_widgets

	_zsh_autosuggest_async_recreate_pty
	add-zsh-hook precmd _zsh_autosuggest_async_recreate_pty
}

add-zsh-hook precmd _zsh_autosuggest_start
