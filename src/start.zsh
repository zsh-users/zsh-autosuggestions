
#--------------------------------------------------------------------#
# Start                                                              #
#--------------------------------------------------------------------#

# Start the autosuggestion widgets
_zsh_autosuggest_start() {
	# By default we re-bind widgets on every precmd to ensure we wrap other
	# wrappers. Specifically, highlighting breaks if our widgets are wrapped by
	# zsh-syntax-highlighting widgets. This also allows modifications to the
	# widget list variables to take effect on the next precmd. However this has
	# a decent performance hit, so users can set ZSH_AUTOSUGGEST_MANUAL_REBIND
	# to disable the automatic re-binding.
	if (( ${+ZSH_AUTOSUGGEST_MANUAL_REBIND} )); then
		add-zsh-hook -d precmd _zsh_autosuggest_start
	fi

	_zsh_autosuggest_bind_widgets
}

# Mark for auto-loading the functions that we use
autoload -Uz add-zsh-hook is-at-least

# If zle is already running, go ahead and start the autosuggestion widgets.
# Otherwise, wait until the next precmd.
if zle; then
	_zsh_autosuggest_start
	(( ! ${+ZSH_AUTOSUGGEST_MANUAL_REBIND} )) && add-zsh-hook precmd _zsh_autosuggest_start
else
	add-zsh-hook precmd _zsh_autosuggest_start
fi
