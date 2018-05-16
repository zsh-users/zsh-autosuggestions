
#--------------------------------------------------------------------#
# Default Suggestion Strategy                                        #
#--------------------------------------------------------------------#
# Will provide suggestions from your history. If no matches are found
# in history, will provide a suggestion from the completion engine.
#

_zsh_autosuggest_strategy_default() {
	typeset -g suggestion

	_zsh_autosuggest_strategy_history "$1"

	if [[ -z "$suggestion" ]]; then
		_zsh_autosuggest_strategy_completion "$1"
	fi
}
