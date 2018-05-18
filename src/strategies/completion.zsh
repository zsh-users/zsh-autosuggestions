
#--------------------------------------------------------------------#
# Completion Suggestion Strategy                                     #
#--------------------------------------------------------------------#
# Fetches suggestions from zsh's completion engine
#

# Big thanks to https://github.com/Valodim/zsh-capture-completion
_zsh_autosuggest_capture_completion() {
	zpty $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME zsh -f -i

	local line

	setopt rcquotes
	() {
		# Initialize the pty env, blocking until null byte is seen
		zpty -w $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME "source $1"
		zpty -r $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME line '*'$'\0'
	} =( <<< '
	exec 2>/dev/null # Silence any error messages

	autoload compinit
	compinit -d ~/.zcompdump_autosuggestions

	# Exit as soon as completion is finished
	comppostfuncs=( exit )

	# Never group stuff!
	zstyle '':completion:*'' list-grouped false

	# no list separator, this saves some stripping later on
	zstyle '':completion:*'' list-separator ''''

	# we use zparseopts
	zmodload zsh/zutil

	# override compadd (this our hook)
	compadd () {
		# Just delegate and leave if any of -O, -A or -D are given
		if [[ ${@[1,(i)(-|--)]} == *-(O|A|D)\ * ]]; then
			builtin compadd "$@"
			return $?
		fi

		setopt localoptions norcexpandparam extendedglob

		typeset -a __hits

		# Capture completions by injecting -A parameter into the compadd call.
		# This takes care of matching for us.
		builtin compadd -A __hits "$@"

		# Exit if no completion results
		[[ -n $__hits ]] || return

		# Extract prefixes and suffixes from compadd call. we can''t do zsh''s cool
		# -r remove-func magic, but it''s better than nothing.
		typeset -A apre hpre hsuf asuf
		zparseopts -E P:=apre p:=hpre S:=asuf s:=hsuf

		# Print the first match
		echo -nE - $''\0''$IPREFIX$apre$hpre$__hits[1]$dsuf$hsuf$asuf$''\0''
	}

	# Signal setup completion by sending null byte
	echo $''\0''
	')

	# Send the string and a tab to trigger completion
	zpty -w $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME "$*"$'\t'

	# Read up to the start of the first result
	zpty -r $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME line '*'$'\0'

	# Read the first result
	zpty -r $ZSH_AUTOSUGGEST_COMPLETIONS_PTY_NAME line '*'$'\0'

	# Print it, removing the trailing null byte
	echo -E - ${line%$'\0'}
}

_zsh_autosuggest_strategy_completion() {
	typeset -g suggestion=$(_zsh_autosuggest_capture_completion "$1" | head -n 1)

	# Strip the trailing carriage return
	suggestion="${suggestion%$'\r'}"

	# Add the completion string to the buffer to build the full suggestion
	local -i i=1
	while [[ "$suggestion" != "${1[$i,-1]}"* ]]; do ((i++)); done
	suggestion="${1[1,$i-1]}$suggestion"
}
