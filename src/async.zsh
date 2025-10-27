
#--------------------------------------------------------------------#
# Async                                                              #
#--------------------------------------------------------------------#

_zsh_autosuggest_async_cancel() {
	if [[ -n "$_ZSH_AUTOSUGGEST_ASYNC_FD" ]] && { true <&$_ZSH_AUTOSUGGEST_ASYNC_FD } 2>/dev/null; then
		# Close the file descriptor and remove the handler
		builtin exec {_ZSH_AUTOSUGGEST_ASYNC_FD}<&-
		zle -F $_ZSH_AUTOSUGGEST_ASYNC_FD
	fi

	if [[ -n "$_ZSH_AUTOSUGGEST_CHILD_PID" ]]; then
		# Zsh will make a new process group for the child process only if job
		# control is enabled (MONITOR option)
		if [[ -o MONITOR ]]; then
			# Send the signal to the process group to kill any processes that may
			# have been forked by the suggestion strategy
			kill -TERM -$_ZSH_AUTOSUGGEST_CHILD_PID 2>/dev/null
		else
			# Kill just the child process since it wasn't placed in a new process
			# group. If the suggestion strategy forked any child processes they may
			# be orphaned and left behind.
			kill -TERM $_ZSH_AUTOSUGGEST_CHILD_PID 2>/dev/null
		fi
	fi

	_ZSH_AUTOSUGGEST_ASYNC_FD=
	_ZSH_AUTOSUGGEST_CHILD_PID=
}

_zsh_autosuggest_async_request() {
	zmodload zsh/system 2>/dev/null # For `$sysparams`

	typeset -g _ZSH_AUTOSUGGEST_ASYNC_FD _ZSH_AUTOSUGGEST_CHILD_PID

	local buffer="$1"
	local -i offset=${2:-0}

	_zsh_autosuggest_async_cancel

	typeset -g _ZSH_AUTOSUGGEST_PENDING_BUFFER _ZSH_AUTOSUGGEST_PENDING_OFFSET
	_ZSH_AUTOSUGGEST_PENDING_BUFFER="$buffer"
	_ZSH_AUTOSUGGEST_PENDING_OFFSET=$offset

	# Fork a process to fetch a suggestion and open a pipe to read from it
	builtin exec {_ZSH_AUTOSUGGEST_ASYNC_FD}< <(
		# Tell parent process our pid
		echo $sysparams[pid]

		# Fetch and print the suggestion
		local suggestion
		_zsh_autosuggest_fetch_suggestion "$buffer" $offset
		echo -nE "$suggestion"
	)

	# There's a weird bug here where ^C stops working unless we force a fork
	# See https://github.com/zsh-users/zsh-autosuggestions/issues/364
	autoload -Uz is-at-least
	is-at-least 5.8 || command true

	# Read the pid from the child process
	read _ZSH_AUTOSUGGEST_CHILD_PID <&$_ZSH_AUTOSUGGEST_ASYNC_FD

	# When the fd is readable, call the response handler
	zle -F "$_ZSH_AUTOSUGGEST_ASYNC_FD" _zsh_autosuggest_async_response
}

# Called when new data is ready to be read from the pipe
# First arg will be fd ready for reading
# Second arg will be passed in case of error
_zsh_autosuggest_async_response() {
	emulate -L zsh

	local suggestion

	if [[ -z "$2" || "$2" == "hup" ]]; then
		# Read everything from the fd and give it as a suggestion
		IFS='' read -rd '' -u $1 suggestion
		if [[ -n "$suggestion" && "$suggestion" = "$BUFFER"* ]]; then
			typeset -g _ZSH_AUTOSUGGEST_SUGGESTION_INDEX _ZSH_AUTOSUGGEST_LAST_PREFIX
			if [[ -n "${_ZSH_AUTOSUGGEST_PENDING_BUFFER-}" && "$BUFFER" = "$_ZSH_AUTOSUGGEST_PENDING_BUFFER" ]]; then
				_ZSH_AUTOSUGGEST_SUGGESTION_INDEX=${_ZSH_AUTOSUGGEST_PENDING_OFFSET:-0}
				_ZSH_AUTOSUGGEST_LAST_PREFIX="$BUFFER"
			else
				# Fall back to updating state using the current buffer if it still
				# matches the suggestion.
				_ZSH_AUTOSUGGEST_SUGGESTION_INDEX=${_ZSH_AUTOSUGGEST_PENDING_OFFSET:-0}
				_ZSH_AUTOSUGGEST_LAST_PREFIX="$BUFFER"
			fi
		elif [[ -z "$suggestion" ]]; then
			typeset -g _ZSH_AUTOSUGGEST_SUGGESTION_INDEX _ZSH_AUTOSUGGEST_LAST_PREFIX
			_ZSH_AUTOSUGGEST_SUGGESTION_INDEX=0
			_ZSH_AUTOSUGGEST_LAST_PREFIX="$BUFFER"
		fi
		zle autosuggest-suggest -- "$suggestion"

		# Close the fd
		builtin exec {1}<&-
	fi

	# Always remove the handler
	zle -F "$1"
	_ZSH_AUTOSUGGEST_ASYNC_FD=
	_ZSH_AUTOSUGGEST_CHILD_PID=

	typeset -g _ZSH_AUTOSUGGEST_PENDING_BUFFER _ZSH_AUTOSUGGEST_PENDING_OFFSET
	unset _ZSH_AUTOSUGGEST_PENDING_BUFFER
	_ZSH_AUTOSUGGEST_PENDING_OFFSET=0
}
