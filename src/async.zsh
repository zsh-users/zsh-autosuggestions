
#--------------------------------------------------------------------#
# Async                                                              #
#--------------------------------------------------------------------#

_zsh_autosuggest_async_fetch_suggestion() {
	local strategy_function="_zsh_autosuggest_strategy_$ZSH_AUTOSUGGEST_STRATEGY"
	local prefix="$(_zsh_autosuggest_escape_command "$1")"

	# Send the suggestion command to the pty to fetch a suggestion
	zpty -w -n $ZSH_AUTOSUGGEST_PTY_NAME "$strategy_function '$prefix'"$'\0'
}

_zsh_autosuggest_async_suggestion_worker() {
	local last_pid

	while read -d $'\0' cmd; do
		# Kill last bg process
		kill -KILL $last_pid &>/dev/null

		# Run suggestion search in the background
		print -n -- "$(eval "$cmd")"$'\0' &

		# Save the bg process's id so we can kill later
		last_pid=$!
	done
}

_zsh_autosuggest_async_suggestion_ready() {
	# while zpty -rt $ZSH_AUTOSUGGEST_PTY_NAME suggestion 2>/dev/null; do
	while read -u $_ZSH_AUTOSUGGEST_PTY_FD -d $'\0' suggestion; do
		zle _autosuggest-show-suggestion "${suggestion//$'\r'$'\n'/$'\n'}"
	done
}

# Recreate the pty to get a fresh list of history events
_zsh_autosuggest_async_recreate_pty() {
	typeset -g _ZSH_AUTOSUGGEST_PTY_FD

	# Kill the old pty
	if [ -n "$_ZSH_AUTOSUGGEST_PTY_FD" ]; then
		zle -F $_ZSH_AUTOSUGGEST_PTY_FD
		zpty -d $ZSH_AUTOSUGGEST_PTY_NAME &>/dev/null
	fi

	# Start a new pty
	typeset -h REPLY
	zpty -b $ZSH_AUTOSUGGEST_PTY_NAME _zsh_autosuggest_async_suggestion_worker
	_ZSH_AUTOSUGGEST_PTY_FD=$REPLY
	zle -F $_ZSH_AUTOSUGGEST_PTY_FD _zsh_autosuggest_async_suggestion_ready
}

add-zsh-hook precmd _zsh_autosuggest_async_recreate_pty
