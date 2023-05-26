
#--------------------------------------------------------------------#
# Async                                                              #
#--------------------------------------------------------------------#

_zsh_autosuggest_async_request() {
	zmodload zsh/system 2>/dev/null # For `$sysparams`

	typeset -g _ZSH_AUTOSUGGEST_ASYNC_FD _ZSH_AUTOSUGGEST_CHILD_PID

	# If we've got a pending request, cancel it
	if [[ -n "$_ZSH_AUTOSUGGEST_ASYNC_FD" ]] && { true <&$_ZSH_AUTOSUGGEST_ASYNC_FD } 2>/dev/null; then
		# Close the file descriptor and remove the handler
		exec {_ZSH_AUTOSUGGEST_ASYNC_FD}<&-
		zle -F $_ZSH_AUTOSUGGEST_ASYNC_FD

		# We won't know the pid unless the user has zsh/system module installed
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
	fi

	# Fork a process to fetch a suggestion and open a pipe to read from it
	exec {_ZSH_AUTOSUGGEST_ASYNC_FD}< <(
		# Tell parent process our pid
		echo $sysparams[pid]

		# Fetch and print the suggestion
		local suggestion
		_zsh_autosuggest_fetch_suggestion "$1"
		echo -nE "$suggestion"
	)

	# There's a weird bug here where ^C stops working unless we force a fork
	# See https://github.com/zsh-users/zsh-autosuggestions/issues/364
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
		_zsh_autosuggest_async_suggest "$suggestion"

		# Close the fd
		exec {1}<&-
	fi

	# Always remove the handler
	zle -F "$1"
}

_zsh_autosuggest_async_suggest() {
	# Before 5.9, async suggestions break widgets that rely on LASTWIDGET
	# such as copy-earlier-word and {up,down}-line-or-beginning-search. In
	# 5.9, a flag was added to `zle` that will skip setting LASTWIDGET so
	# that those widgets that depend on it will continue to work
	# See https://www.zsh.org/mla/workers/2020/msg00824.html
	local nolast
	is-at-least 5.9 && nolast=supported
	zle autosuggest-suggest ${=nolast:+-f nolast} -- "$1"
}
