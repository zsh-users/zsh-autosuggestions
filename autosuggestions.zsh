#
# Fish-like autosuggestions for zsh
#
# ```zsh
# zle-line-init() {
#     autosuggest_start
# }
# zle -N zle-line-init
# ```

unset _ZSH_AUTOSUGGESTION_ACTIVE

LIBDIR="${0:a:h}/lib"

source "$LIBDIR/config.zsh"
source "$LIBDIR/get_suggestion.zsh"
source "$LIBDIR/highlight.zsh"
source "$LIBDIR/widget/widgets.zsh"
source "$LIBDIR/widget/hook.zsh"

autosuggest_start() {
	_ZSH_AUTOSUGGESTION_ACTIVE=true

	# Register highlighter if needed to support zsh-syntax-highlighting plugin
	if _zsh_autosuggest_syntax_highlighting_enabled; then
		_zsh_autosuggest_register_highlighter
	fi

	_zsh_autosuggest_hook_widgets
}
