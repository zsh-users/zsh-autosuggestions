
#--------------------------------------------------------------------#
# Completion Suggestion Strategy                                     #
#--------------------------------------------------------------------#
# Fetches suggestions from zsh's completion engine
# Based on https://github.com/Valodim/zsh-capture-completion
#

_zsh_autosuggest_capture_setup() {
	zmodload zsh/zutil # For `zparseopts`

	# There is a bug in zpty module (fixed in zsh/master) by which a
	# zpty that exits will kill all zpty processes that were forked
	# before it. Here we set up a zsh exit hook to SIGKILL the zpty
	# process immediately, before it has a chance to kill any other
	# zpty processes.
	zshexit() {
		kill -KILL $$
		sleep 1 # Block for long enough for the signal to come through
	}

	# Never group stuff!
	zstyle ':completion:*' list-grouped false

	# No list separator, this saves some stripping later on
	zstyle ':completion:*' list-separator ''

	# Override compadd (this is our hook)
	compadd () {
		setopt localoptions norcexpandparam

		# Just delegate and leave if any of -O, -A or -D are given
		if [[ ${@[1,(i)(-|--)]} == *-(O|A|D)\ * ]]; then
			builtin compadd "$@"
			return $?
		fi

		# Capture completions by injecting -A parameter into the compadd call.
		# This takes care of matching for us.
		typeset -a __hits
		builtin compadd -A __hits "$@"

		# Exit if no completion results
		[[ -n $__hits ]] || return

		# Extract prefixes and suffixes from compadd call. we can't do zsh's cool
		# -r remove-func magic, but it's better than nothing.
		typeset -A apre hpre hsuf asuf
		zparseopts -E P:=apre p:=hpre S:=asuf s:=hsuf

		# Print the first match
		echo -nE - $'\0'$IPREFIX$apre$hpre$__hits[1]$dsuf$hsuf$asuf$'\0'
	}
}

_zsh_autosuggest_capture_widget() {
	_zsh_autosuggest_capture_setup

	zle complete-word
}

zle -N autosuggest-capture-completion _zsh_autosuggest_capture_widget

_zsh_autosuggest_capture_buffer() {
	local BUFFERCONTENT="$1"

	_zsh_autosuggest_capture_setup

	zmodload zsh/parameter # For `$functions`

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

_zsh_autosuggest_capture_completion() {
	typeset -g completion
	local line

	# Zle will be inactive if we are in async mode
	if zle; then
		zpty $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME zle autosuggest-capture-completion
	else
		zpty $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME "_zsh_autosuggest_capture_buffer '$1'"
		zpty -w $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME $'\t'
	fi

	# The completion result is surrounded by null bytes, so read the
	# content between the first two null bytes.
	zpty -r $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME line '*'$'\0'
	zpty -r $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME line '*'$'\0'
	completion="${line%$'\0'}"

	# Destroy the pty
	zpty -d $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME
}

_zsh_autosuggest_strategy_completion() {
	typeset -g suggestion completion

	# Fetch the first completion result
	_zsh_autosuggest_capture_completion "$1"

	# Add the completion string to the buffer to build the full suggestion
	local -i i=1
	while [[ "$completion" != "${1[$i,-1]}"* ]]; do ((i++)); done
	suggestion="${1[1,$i-1]}$completion"
}
