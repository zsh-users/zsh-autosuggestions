_zsh_autosuggest_get_suggestion() {
	local prefix=$1
	local history_items=(${history[(R)$prefix*]})

	for cmd in $history_items; do
		if [ "${cmd:0:$#prefix}" = "$prefix" ]; then
			echo $cmd
			break
		fi
	done
}
