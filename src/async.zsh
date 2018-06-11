
#--------------------------------------------------------------------#
# Async                                                              #
#--------------------------------------------------------------------#

_zsh_autosuggest_async_request() {
	typeset -g _ZSH_AUTOSUGGEST_ASYNC_FD

	# Close the last fd to invalidate old suggestions
	if [[ -n "$_ZSH_AUTOSUGGEST_ASYNC_FD" ]] && { true <&$_ZSH_AUTOSUGGEST_ASYNC_FD } 2>/dev/null; then
		exec {_ZSH_AUTOSUGGEST_ASYNC_FD}<&-
	fi

	# Fork a process to fetch a suggestion and open a pipe to read from it
	exec {_ZSH_AUTOSUGGEST_ASYNC_FD}< <(
		local suggestion
		_zsh_autosuggest_fetch_suggestion "$1"
		echo -nE "$suggestion"
	)

	# When the fd is readable, call the response handler
	zle -F "$_ZSH_AUTOSUGGEST_ASYNC_FD" _zsh_autosuggest_async_response
}

# Called when new data is ready to be read from the pipe
# First arg will be fd ready for reading
# Second arg will be passed in case of error
_zsh_autosuggest_async_response() {
	# Read everything from the fd and give it as a suggestion
	zle autosuggest-suggest -- "$(<&$1)"

	# Remove the handler and close the fd
	zle -F "$1"
	exec {1}<&-
}
