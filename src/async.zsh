
#--------------------------------------------------------------------#
# Async                                                              #
#--------------------------------------------------------------------#

# Zpty process is spawned running this function
_zsh_autosuggest_async_server() {
	emulate -R zsh

	# There is a bug in zpty module (fixed in zsh/master) by which a
	# zpty that exits will kill all zpty processes that were forked
	# before it. Here we set up a zsh exit hook to SIGKILL the zpty
	# process immediately, before it has a chance to kill any other
	# zpty processes.
	zshexit() {
		kill -KILL $$
		sleep 1 # Block for long enough for the signal to come through
	}

	# Output only newlines (not carriage return + newline)
	stty -onlcr

	# Silence any error messages
	exec 2>/dev/null

	local strategy=$1
	local last_pid

	while IFS='' read -r -d $'\0' query; do
		# Kill last bg process
		kill -KILL $last_pid &>/dev/null

		# Run suggestion search in the background
		(
			local suggestion
			_zsh_autosuggest_strategy_$ZSH_AUTOSUGGEST_STRATEGY "$query"
			echo -n -E "$suggestion"$'\0'
		) &

		last_pid=$!
	done
}

_zsh_autosuggest_async_request() {
	# Write the query to the zpty process to fetch a suggestion
	zpty -w -n $ZSH_AUTOSUGGEST_ASYNC_PTY_NAME "${1}"$'\0'
}

# Called when new data is ready to be read from the pty
# First arg will be fd ready for reading
# Second arg will be passed in case of error
_zsh_autosuggest_async_response() {
	setopt LOCAL_OPTIONS EXTENDED_GLOB

	local suggestion

	zpty -rt $ZSH_AUTOSUGGEST_ASYNC_PTY_NAME suggestion '*'$'\0' 2>/dev/null
	zle autosuggest-suggest -- "${suggestion%%$'\0'##}"
}

_zsh_autosuggest_async_pty_create() {
	# With newer versions of zsh, REPLY stores the fd to read from
	typeset -h REPLY

	# If we won't get a fd back from zpty, try to guess it
	if [ $_ZSH_AUTOSUGGEST_ZPTY_RETURNS_FD -eq 0 ]; then
		integer -l zptyfd
		exec {zptyfd}>&1  # Open a new file descriptor (above 10).
		exec {zptyfd}>&-  # Close it so it's free to be used by zpty.
	fi

	# Fork a zpty process running the server function
	zpty -b $ZSH_AUTOSUGGEST_ASYNC_PTY_NAME "_zsh_autosuggest_async_server _zsh_autosuggest_strategy_$ZSH_AUTOSUGGEST_STRATEGY"

	# Store the fd so we can remove the handler later
	if (( REPLY )); then
		_ZSH_AUTOSUGGEST_PTY_FD=$REPLY
	else
		_ZSH_AUTOSUGGEST_PTY_FD=$zptyfd
	fi

	# Set up input handler from the zpty
	zle -F $_ZSH_AUTOSUGGEST_PTY_FD _zsh_autosuggest_async_response
}

_zsh_autosuggest_async_pty_destroy() {
	if zpty -t $ZSH_AUTOSUGGEST_ASYNC_PTY_NAME &>/dev/null; then
		# Remove the input handler
		zle -F $_ZSH_AUTOSUGGEST_PTY_FD &>/dev/null

		# Destroy the zpty
		zpty -d $ZSH_AUTOSUGGEST_ASYNC_PTY_NAME &>/dev/null
	fi
}

_zsh_autosuggest_async_pty_recreate() {
	_zsh_autosuggest_async_pty_destroy
	_zsh_autosuggest_async_pty_create
}

_zsh_autosuggest_async_start() {
	typeset -g _ZSH_AUTOSUGGEST_PTY_FD

	_zsh_autosuggest_feature_detect_zpty_returns_fd
	_zsh_autosuggest_async_pty_recreate

	# We recreate the pty to get a fresh list of history events
	add-zsh-hook precmd _zsh_autosuggest_async_pty_recreate
}
