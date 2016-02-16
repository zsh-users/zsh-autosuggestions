
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
	# Original widget modifies the buffer
	_zsh_autosuggest_invoke_original_widget $@

	# Get a new suggestion if the buffer is not empty after modification
	local suggestion
	if [ $#BUFFER -gt 0 ]; then
		suggestion=$(_zsh_autosuggest_suggestion "$BUFFER")
	fi

	# Add the suggestion to the POSTDISPLAY
	if [ -n "$suggestion" ]; then
		POSTDISPLAY=${suggestion#$BUFFER}
	else
		unset POSTDISPLAY
	fi
}

# Accept the entire suggestion
_zsh_autosuggest_accept() {
	# Only accept if the cursor is at the end of the buffer
	if [ $CURSOR -eq $#BUFFER ]; then
		# Add the suggestion to the buffer
		BUFFER="$BUFFER$POSTDISPLAY"

		# Remove the suggestion
		unset POSTDISPLAY

		# Move the cursor to the end of the buffer
		CURSOR=${#BUFFER}
	fi

	_zsh_autosuggest_invoke_original_widget $@
}

# Partially accept the suggestion
_zsh_autosuggest_partial_accept() {
	# Save the contents of the buffer so we can restore later if needed
	local original_buffer=$BUFFER

	# Temporarily accept the suggestion.
	BUFFER="$BUFFER$POSTDISPLAY"

	# Original widget moves the cursor
	_zsh_autosuggest_invoke_original_widget $@

	# If we've moved past the end of the original buffer
	if [ $CURSOR -gt $#original_buffer ]; then
		# Set POSTDISPLAY to text right of the cursor
		POSTDISPLAY=$RBUFFER

		# Clip the buffer at the cursor
		BUFFER=$LBUFFER
	else
		# Restore the original buffer
		BUFFER=$original_buffer
	fi
}

for action in clear modify accept partial_accept; do
	eval "_zsh_autosuggest_widget_$action() {
		_zsh_autosuggest_highlight_reset
		_zsh_autosuggest_$action \$@
		_zsh_autosuggest_highlight_apply
	}"
done

zle -N autosuggest-accept _zsh_autosuggest_widget_accept
zle -N autosuggest-clear _zsh_autosuggest_widget_clear
