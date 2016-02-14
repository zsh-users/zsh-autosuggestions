
#--------------------------------------------------------------------#
# Start                                                              #
#--------------------------------------------------------------------#

# Start the autosuggestion widgets
_zsh_autosuggest_start() {
	_zsh_autosuggest_check_deprecated_config
	_zsh_autosuggest_bind_widgets
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_autosuggest_start
