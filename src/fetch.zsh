
#--------------------------------------------------------------------#
# Fetch Suggestion                                                   #
#--------------------------------------------------------------------#
# Loops through all specified strategies and returns a suggestion
# from the first strategy to provide one.
#

_zsh_autosuggest_fetch_suggestion() {
	typeset -g suggestion
	local -a strategy_specs spec_parts strategies
	local strategy_spec strategy prefix

	# Ensure we are working with an array
	strategy_specs=(${ZSH_AUTOSUGGEST_STRATEGY})

	echo "fetching.." >> debug.log

	for strategy_spec in $strategy_specs; do
		echo "trying spec: '$strategy_spec'" >> debug.log
		spec_parts=(${(s/:/)strategy_spec})
		prefix="${spec_parts[1]}"

		echo "checking prefix: $prefix" >> debug.log
		echo "  spec parts: $spec_parts" >> debug.log

		if [[ "$1" != ${~prefix} ]]; then
			echo "  '$1' didn't match prefix: '$prefix'" >> debug.log
			continue;
		fi

		strategies=(${(s/,/)${spec_parts[2]}})

		echo "  trying strategies: $strategies" >> debug.log

		for strategy in $strategies; do

			echo "    trying strategy $strategy" >> debug.log

			# Try to get a suggestion from this strategy
			_zsh_autosuggest_strategy_$strategy "$1"

			# Ensure the suggestion matches the prefix
			[[ "$suggestion" != "$1"* ]] && unset suggestion

			# Break once we've found a valid suggestion
			[[ -n "$suggestion" ]] && return

			echo "      didn't get suggestion" >> debug.log
		done
	done
}
