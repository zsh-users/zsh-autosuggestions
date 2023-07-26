
#--------------------------------------------------------------------#
# Async                                                              #
#--------------------------------------------------------------------#

_zsh_autosuggest_async_request() {
	zmodload zsh/system 2>/dev/null # For `$sysparams`

	typeset -g _ZSH_AUTOSUGGEST_ASYNC_FD _ZSH_AUTOSUGGEST_CHILD_PID

	# If we've got a pending request, cancel it
	if (( _ZSH_AUTOSUGGEST_CHILD_PID )); then
		kill -TERM -- $_ZSH_AUTOSUGGEST_CHILD_PID 2>/dev/null
		_ZSH_AUTOSUGGEST_CHILD_PID=
	fi

	_ZSH_AUTOSUGGEST_ASYNC_FD=

	{
		# Fork a process to fetch a suggestion and open a pipe to read from it
		exec {_ZSH_AUTOSUGGEST_ASYNC_FD}< <(
			# Suppress error messages
			exec 2>/dev/null

			# Tell parent process our pid
			if (( ${+sysparams} )); then
				echo ${sysparams[pid]} || return
			else
				echo || return
			fi

			# Fetch and print the suggestion
			local suggestion
			_zsh_autosuggest_fetch_suggestion "$1"
			echo -nE - "$suggestion"
		) || return

		# There's a weird bug here where ^C stops working unless we force a fork
		# See https://github.com/zsh-users/zsh-autosuggestions/issues/364
		autoload -Uz is-at-least
		is-at-least 5.8 || command true

		# Read the pid from the child process
		read _ZSH_AUTOSUGGEST_CHILD_PID <&$_ZSH_AUTOSUGGEST_ASYNC_FD || return

		# Zsh will make a new process group for the child process only if job
		# control is enabled (MONITOR option)
		if [[ -o MONITOR ]]; then
			# If we need to kill the background process in the future, we'll send
			# SIGTERM to the process group to kill any processes that may have
			# been forked by the suggestion strategy
			_ZSH_AUTOSUGGEST_CHILD_PID=-$_ZSH_AUTOSUGGEST_CHILD_PID
		fi

		# When the fd is readable, call the response handler
		zle -F "$_ZSH_AUTOSUGGEST_ASYNC_FD" _zsh_autosuggest_async_response
	} always {
		# Clean things up if there was an error
		if (( $? && _ZSH_AUTOSUGGEST_ASYNC_FD )); then
			exec {_ZSH_AUTOSUGGEST_ASYNC_FD}<&-
			_ZSH_AUTOSUGGEST_ASYNC_FD=
			_ZSH_AUTOSUGGEST_CHILD_PID=
		fi
	}
}

# Called when new data is ready to be read from the pipe
# First arg will be fd ready for reading
# Second arg will be passed in case of error
_zsh_autosuggest_async_response() {
	emulate -L zsh

	local suggestion
	if (( $1 == _ZSH_AUTOSUGGEST_ASYNC_FD )); then
		_ZSH_AUTOSUGGEST_ASYNC_FD=
		_ZSH_AUTOSUGGEST_CHILD_PID=
		if [[ $# == 1 || $2 == "hup" ]]; then
			# Read everything from the fd
			IFS='' read -rd '' -u $1 suggestion
		fi
	fi

	# Always remove the handler and close the fd
	zle -F $1
	exec {1}<&-

	if [[ -n $suggestion ]]; then
		zle autosuggest-suggest -- "$suggestion"
	fi
}
