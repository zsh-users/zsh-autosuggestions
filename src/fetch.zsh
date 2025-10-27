
#--------------------------------------------------------------------#
# Fetch Suggestion                                                   #
#--------------------------------------------------------------------#
# Loops through all specified strategies and returns a suggestion
# from the first strategy to provide one.
#

_zsh_autosuggest_fetch_suggestion() {
	typeset -g suggestion
	local prefix="$1"
	local -i remaining_offset=${2:-0}
	local -a strategies
	local strategy
	local reply_value
	local -i strategy_count

	# Ensure we are working with an array
	strategies=(${=ZSH_AUTOSUGGEST_STRATEGY})

	# Reset global suggestion result
	unset suggestion

	for strategy in $strategies; do
		reply_value=
		REPLY=

		# Try to get a suggestion from this strategy
		_zsh_autosuggest_strategy_$strategy "$prefix" $remaining_offset

		# Ensure the suggestion matches the prefix
		if [[ "$suggestion" != "$prefix"* ]]; then
			unset suggestion
		fi

		# Break once we've found a valid suggestion
		if [[ -n "$suggestion" ]]; then
			break
		fi

		# Determine how many suggestions this strategy can offer so we can
		# decrement the remaining offset before trying the next strategy.
		reply_value="$REPLY"
		if [[ -n "$reply_value" && "$reply_value" = <-> ]]; then
			strategy_count=$reply_value
		elif [[ -n "$reply_value" ]]; then
			# Treat non-numeric replies as zero to avoid arithmetic errors
			strategy_count=0
		else
			# Preserve existing behaviour when the strategy doesn't report a count.
			strategy_count=0
		fi

		if (( remaining_offset > 0 && strategy_count > 0 )); then
			if (( remaining_offset >= strategy_count )); then
				remaining_offset=$((remaining_offset - strategy_count))
			else
				remaining_offset=0
			fi
		fi
	done
}
