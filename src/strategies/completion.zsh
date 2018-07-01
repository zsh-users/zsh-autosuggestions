
#--------------------------------------------------------------------#
# Completion Suggestion Strategy                                     #
#--------------------------------------------------------------------#
# Fetches a suggestion from the completion engine
#

_zsh_autosuggest_capture_postcompletion() {
	# Always insert the first completion into the buffer
	compstate[insert]=1

	# Don't list completions
	unset compstate[list]
}

_zsh_autosuggest_capture_completion_widget() {
	# There is a bug in zpty module (fixed in zsh/master) by which a
	# zpty that exits will kill all zpty processes that were forked
	# before it. Here we set up a zsh exit hook to SIGKILL the zpty
	# process immediately, before it has a chance to kill any other
	# zpty processes.
	zshexit() {
		kill -KILL $$
		sleep 1 # Block for long enough for the signal to come through
	}

	local -a +h comppostfuncs
	comppostfuncs=(_zsh_autosuggest_capture_postcompletion)

	# Run the original widget wrapping `.complete-word` so we don't
	# recursively try to fetch suggestions, since our pty is forked
	# after autosuggestions is initialized.
	zle -- ${(k)widgets[(r)completion:.complete-word:_main_complete]}

	# The completion has been added, print the buffer as the suggestion
	echo -nE - $'\0'$BUFFER$'\0'
}

zle -N autosuggest-capture-completion _zsh_autosuggest_capture_completion_widget

_zsh_autosuggest_capture_buffer() {
	local BUFFERCONTENT="$1"

	zmodload zsh/parameter 2>/dev/null || return # For `$functions`

	bindkey '^I' autosuggest-capture-completion

	# Make vared completion work as if for a normal command line
	# https://stackoverflow.com/a/7057118/154703
	autoload +X _complete
	functions[_original_complete]=$functions[_complete]
	_complete () {
		unset 'compstate[vared]'
		_original_complete "$@"
	}

	# Open zle with buffer set so we can capture completions for it
	vared BUFFERCONTENT
}

_zsh_autosuggest_strategy_completion() {
	typeset -g suggestion
	local line REPLY

	# Exit if we don't have completions
	whence compdef >/dev/null || return

	# Exit if we don't have zpty
	zmodload zsh/zpty 2>/dev/null || return

	# Zle will be inactive if we are in async mode
	if zle; then
		zpty $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME zle autosuggest-capture-completion
	else
		zpty $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME _zsh_autosuggest_capture_buffer "\$1"
		zpty -w $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME $'\t'
	fi

	# The completion result is surrounded by null bytes, so read the
	# content between the first two null bytes.
	zpty -r $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME line '*'$'\0''*'$'\0'

	# On older versions of zsh, we sometimes get extra bytes after the
	# second null byte, so trim those off the end
	suggestion="${${${(M)line:#*$'\0'*$'\0'*}#*$'\0'}%%$'\0'*}"

	# Destroy the pty
	zpty -d $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME
}
