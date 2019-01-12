
#--------------------------------------------------------------------#
# Autosuggest Widget Implementations                                 #
#--------------------------------------------------------------------#

# Disable suggestions
_zsh_autosuggest_disable() {
	typeset -g _ZSH_AUTOSUGGEST_DISABLED
	_zsh_autosuggest_clear
}

# Enable suggestions
_zsh_autosuggest_enable() {
	unset _ZSH_AUTOSUGGEST_DISABLED

	if (( $#BUFFER )); then
		_zsh_autosuggest_fetch
	fi
}

# Toggle suggestions (enable/disable)
_zsh_autosuggest_toggle() {
	if [[ -n "${_ZSH_AUTOSUGGEST_DISABLED+x}" ]]; then
		_zsh_autosuggest_enable
	else
		_zsh_autosuggest_disable
	fi
}

# Clear the suggestion
_zsh_autosuggest_clear() {
	# Remove the suggestion
	unset POSTDISPLAY

	_zsh_autosuggest_invoke_original_widget $@
}

# Modify the buffer and get a new suggestion
_zsh_autosuggest_modify() {
	local -i retval

	# Save the contents of the postdisplay
	local orig_postdisplay="$POSTDISPLAY"

	# Clear suggestion while original widget runs
	unset POSTDISPLAY

	# Original widget may modify the buffer
	_zsh_autosuggest_invoke_original_widget $@
	retval=$?

	# Restore postdisplay to be used in redraw
	POSTDISPLAY="$orig_postdisplay"

	# Run redraw to fetch a suggestion if needed
	_zsh_autosuggest_redraw

	return $retval
}

# Fetch a new suggestion based on what's currently in the buffer
_zsh_autosuggest_fetch() {
	if zpty -t "$ZSH_AUTOSUGGEST_ASYNC_PTY_NAME" &>/dev/null; then
		_zsh_autosuggest_async_request "$BUFFER"
	else
		local suggestion
		_zsh_autosuggest_fetch_suggestion "$BUFFER"
		_zsh_autosuggest_suggest "$suggestion"
	fi
}

# Offer a suggestion
_zsh_autosuggest_suggest() {
	emulate -L zsh

	local suggestion="$1"

	if [[ -n "$suggestion" ]] && (( $#BUFFER )); then
		POSTDISPLAY="${suggestion#$BUFFER}"
	else
		unset POSTDISPLAY
	fi
}

# Accept the entire suggestion
_zsh_autosuggest_accept() {
	local -i max_cursor_pos=$#BUFFER

	# When vicmd keymap is active, the cursor can't move all the way
	# to the end of the buffer
	if [[ "$KEYMAP" = "vicmd" ]]; then
		max_cursor_pos=$((max_cursor_pos - 1))
	fi

	# Only accept if the cursor is at the end of the buffer
	if [[ $CURSOR = $max_cursor_pos ]]; then
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
	local -i retval cursor_loc

	# Save the contents of the buffer so we can restore later if needed
	local original_buffer="$BUFFER"

	# Temporarily accept the suggestion.
	BUFFER="$BUFFER$POSTDISPLAY"

	# Original widget moves the cursor
	_zsh_autosuggest_invoke_original_widget $@
	retval=$?

	# Normalize cursor location across vi/emacs modes
	cursor_loc=$CURSOR
	if [[ "$KEYMAP" = "vicmd" ]]; then
		cursor_loc=$((cursor_loc + 1))
	fi

	# If we've moved past the end of the original buffer
	if (( $cursor_loc > $#original_buffer )); then
		# Set POSTDISPLAY to text right of the cursor
		POSTDISPLAY="${BUFFER[$(($cursor_loc + 1)),$#BUFFER]}"

		# Clip the buffer at the cursor
		BUFFER="${BUFFER[1,$cursor_loc]}"
	else
		# Restore the original buffer
		BUFFER="$original_buffer"
	fi

	return $retval
}

_zsh_autosuggest_redraw() {
	emulate -L zsh

	typeset -g _ZSH_AUTOSUGGEST_LAST_BUFFER

	# Only available in zsh >= 5.4
	local -i KEYS_QUEUED_COUNT

	local orig_buffer="$_ZSH_AUTOSUGGEST_LAST_BUFFER"
	local widget

	# Store the current state of the buffer for next time
	_ZSH_AUTOSUGGEST_LAST_BUFFER="$BUFFER"

	# Buffer hasn't changed
	[[ "$BUFFER" = "$orig_buffer" ]] && return 0

	local ignore_widgets
	ignore_widgets=(
		$ZSH_AUTOSUGGEST_CLEAR_WIDGETS
		$ZSH_AUTOSUGGEST_ACCEPT_WIDGETS
		$ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS
		$ZSH_AUTOSUGGEST_IGNORE_WIDGETS
	)

	# Don't fetch a new suggestion after mapped widgets
	for widget in $ignore_widgets; do
		[[ "$LASTWIDGET" == "$widget" ]] && return 0
	done

	# Optimize if manually typing in the suggestion
	if (( $#BUFFER > $#orig_buffer )); then
		local added=${BUFFER#$orig_buffer}

		# If the string added matches the beginning of the postdisplay
		if [[ "$added" = "${POSTDISPLAY:0:$#added}" ]]; then
			POSTDISPLAY="${POSTDISPLAY:$#added}"
			return 0
		fi
	fi

	unset POSTDISPLAY

	# Don't fetch a new suggestion if there's more input to be read immediately
	(( $PENDING > 0 )) || (( $KEYS_QUEUED_COUNT > 0 )) && return 0

	# Buffer is empty
	(( ! $#BUFFER )) && return 0

	# Buffer longer than max size
	[[ -n "$ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE" ]] && (( $#BUFFER > $ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE )) && return 0

	# Suggestions disabled
	[[ -n "${_ZSH_AUTOSUGGEST_DISABLED+x}" ]] && return 0

	_zsh_autosuggest_fetch
}

() {
	local action
	for action in clear modify fetch suggest accept partial_accept execute enable disable toggle redraw; do
		eval "_zsh_autosuggest_widget_$action() {
			local -i retval

			_zsh_autosuggest_highlight_reset

			_zsh_autosuggest_$action \$@
			retval=\$?

			_zsh_autosuggest_highlight_apply

			zle -R

			return \$retval
		}"
	done

	zle -N autosuggest-redraw _zsh_autosuggest_widget_redraw
	zle -N autosuggest-fetch _zsh_autosuggest_widget_fetch
	zle -N autosuggest-suggest _zsh_autosuggest_widget_suggest
	zle -N autosuggest-accept _zsh_autosuggest_widget_accept
	zle -N autosuggest-clear _zsh_autosuggest_widget_clear
	zle -N autosuggest-execute _zsh_autosuggest_widget_execute
	zle -N autosuggest-enable _zsh_autosuggest_widget_enable
	zle -N autosuggest-disable _zsh_autosuggest_widget_disable
	zle -N autosuggest-toggle _zsh_autosuggest_widget_toggle
}
