
#--------------------------------------------------------------------#
# Autosuggest Widget Implementations                                 #
#--------------------------------------------------------------------#

# Clear the suggestion
_zsh_autosuggest_clear() {
	# Remove the suggestion
	unset POSTDISPLAY

	_zsh_autosuggest_invoke_original_widget $@
}

# Modify the buffer and get a new suggestion
_zsh_autosuggest_modify() {
	local -i retval

	# Save the contents of the buffer/postdisplay
	local orig_buffer="$BUFFER"
	local orig_postdisplay="$POSTDISPLAY"

	# Clear suggestion while original widget runs
	unset POSTDISPLAY

	# Original widget may modify the buffer
	_zsh_autosuggest_invoke_original_widget $@
	retval=$?

	# Don't fetch a new suggestion if the buffer hasn't changed
	if [ "$BUFFER" = "$orig_buffer" ]; then
		POSTDISPLAY="$orig_postdisplay"
		return $retval
	fi

	# Get a new suggestion if the buffer is not empty after modification
	local suggestion
	if [ $#BUFFER -gt 0 ]; then
		if [ -z "$ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE" -o $#BUFFER -lt "$ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE" ]; then
			suggestion="$(_zsh_autosuggest_suggestion "$BUFFER")"
		fi
	fi

	# Add the suggestion to the POSTDISPLAY
	if [ -n "$suggestion" ]; then
		POSTDISPLAY="${suggestion#$BUFFER}"
	fi

	return $retval
}

# Accept the entire suggestion
_zsh_autosuggest_accept() {
	local -i max_cursor_pos=$#BUFFER

	# When vicmd keymap is active, the cursor can't move all the way
	# to the end of the buffer
	if [ "$KEYMAP" = "vicmd" ]; then
		max_cursor_pos=$((max_cursor_pos - 1))
	fi

	# Only accept if the cursor is at the end of the buffer
	if [ $CURSOR -eq $max_cursor_pos ]; then
		# Add the suggestion to the buffer
		BUFFER="$BUFFER$POSTDISPLAY"

		# Remove the suggestion
		unset POSTDISPLAY

		# Move the cursor to the end of the buffer
		CURSOR=${#BUFFER}
	fi

	_zsh_autosuggest_invoke_original_widget $@
}

# Accept the entire suggestion and execute it
_zsh_autosuggest_execute() {
	# Add the suggestion to the buffer
	BUFFER="$BUFFER$POSTDISPLAY"

	# Remove the suggestion
	unset POSTDISPLAY

	# Call the original `accept-line` to handle syntax highlighting or
	# other potential custom behavior
	_zsh_autosuggest_invoke_original_widget "accept-line"
}

# Partially accept the suggestion
_zsh_autosuggest_partial_accept() {
	local -i retval

	# Save the contents of the buffer so we can restore later if needed
	local original_buffer="$BUFFER"

	# Temporarily accept the suggestion.
	BUFFER="$BUFFER$POSTDISPLAY"

	# Original widget moves the cursor
	_zsh_autosuggest_invoke_original_widget $@
	retval=$?

	# If we've moved past the end of the original buffer
	if [ $CURSOR -gt $#original_buffer ]; then
		# Set POSTDISPLAY to text right of the cursor
		POSTDISPLAY="$RBUFFER"

		# Clip the buffer at the cursor
		BUFFER="$LBUFFER"
	else
		# Restore the original buffer
		BUFFER="$original_buffer"
	fi

	return $retval
}

for action in clear modify accept partial_accept execute; do
	eval "_zsh_autosuggest_widget_$action() {
		local -i retval

		_zsh_autosuggest_highlight_reset

		_zsh_autosuggest_$action \$@
		retval=\$?

		_zsh_autosuggest_highlight_apply

		return \$retval
	}"
done

zle -N autosuggest-accept _zsh_autosuggest_widget_accept
zle -N autosuggest-clear _zsh_autosuggest_widget_clear
zle -N autosuggest-execute _zsh_autosuggest_widget_execute
