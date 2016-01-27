_zsh_autosuggest_is_defined_widget() {
	[ -n "$widgets[$1]" ]
}

_zsh_autosuggest_is_built_in_widget() {
	[ -n "$widgets[.$1]" ]
}

_zsh_autosuggest_is_original_widget_defined() {
	_zsh_autosuggest_is_defined_widget $(_zsh_autosuggest_original_widget $1)
}

_zsh_autosuggest_original_widget() {
	if _zsh_autosuggest_is_built_in_widget $1; then
		echo ".$1"
	else
		echo "_autosuggest_original_$1"
	fi
}

_zsh_autosuggest_hook_widget() {
	local autosuggest_widget=$1
	local widget=$2

	# Skip if the widget does not exist
	if ! _zsh_autosuggest_is_defined_widget $widget; then
		continue
	fi

	# Alias if dot-prefixed alias is unavailable and we haven't already aliased it
	if ! _zsh_autosuggest_is_original_widget_defined $widget; then
		zle -A $widget $(_zsh_autosuggest_original_widget $widget)
	fi

	# Hook it
	zle -A $autosuggest_widget $widget
}

_zsh_autosuggest_hook_widgets() {
	local widget

	for widget in $ZSH_AUTOSUGGEST_MODIFY_WIDGETS; do
		_zsh_autosuggest_hook_widget _zsh_autosuggest_widget_modify $widget
	done

	for widget in $ZSH_AUTOSUGGEST_CLEAR_WIDGETS; do
		_zsh_autosuggest_hook_widget _zsh_autosuggest_widget_clear $widget
	done

	for widget in $ZSH_AUTOSUGGEST_ACCEPT_WIDGETS; do
		_zsh_autosuggest_hook_widget _zsh_autosuggest_widget_accept $widget
	done
}
