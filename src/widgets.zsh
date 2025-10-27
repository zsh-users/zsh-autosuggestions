
#--------------------------------------------------------------------#
# Autosuggest Widget Implementations                                 #
#--------------------------------------------------------------------#

typeset -gi _ZSH_AUTOSUGGEST_SUGGESTION_INDEX=0
typeset -gi _ZSH_AUTOSUGGEST_PENDING_OFFSET=0
typeset -g _ZSH_AUTOSUGGEST_PENDING_BUFFER
typeset -g _ZSH_AUTOSUGGEST_LAST_PREFIX

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

_zsh_autosuggest_next() {
	emulate -L zsh

	# Do nothing if suggestions are disabled or there's no buffer to base suggestions on
	if (( ${+_ZSH_AUTOSUGGEST_DISABLED} )) || (( $#BUFFER == 0 )); then
		return 0
	fi

	local -i current_index=${_ZSH_AUTOSUGGEST_SUGGESTION_INDEX:-0}
	local -i next_index=$((current_index + 1))

	# Fetch synchronously to avoid races
	_zsh_autosuggest_fetch $next_index "sync"

	# If no suggestion at next_index, wrap back to 0
	if (( _ZSH_AUTOSUGGEST_SUGGESTION_INDEX != next_index )); then
		_zsh_autosuggest_fetch 0 "sync"
	fi

	return 0
}

_zsh_autosuggest_previous() {
	emulate -L zsh

	if (( ${+_ZSH_AUTOSUGGEST_DISABLED} )) || (( $#BUFFER == 0 )); then
		return 0
	fi

	local -i current_index=${_ZSH_AUTOSUGGEST_SUGGESTION_INDEX:-0}

	if (( current_index > 0 )); then
		local -i prev_index=$((current_index - 1))
		_zsh_autosuggest_fetch $prev_index "sync"
		return 0
	fi

	# We are at the first suggestion; step forward until we can't to find the last entry.
	_zsh_autosuggest_fetch 0 "sync"

	if [[ -z "$POSTDISPLAY" ]]; then
		return 0
	fi

	local -i probe=0
	local -i last_index=0

	while true; do
		(( probe++ ))
		_zsh_autosuggest_fetch $probe "sync"

		if (( _ZSH_AUTOSUGGEST_SUGGESTION_INDEX == probe )); then
			last_index=$probe
			continue
		fi

		break
	done

	_zsh_autosuggest_fetch $last_index "sync"

	return 0
}
# Toggle suggestions (enable/disable)
_zsh_autosuggest_toggle() {
	if (( ${+_ZSH_AUTOSUGGEST_DISABLED} )); then
		_zsh_autosuggest_enable
	else
		_zsh_autosuggest_disable
	fi
}

# Clear the suggestion
_zsh_autosuggest_clear() {
	# Remove the suggestion
	POSTDISPLAY=
	_ZSH_AUTOSUGGEST_SUGGESTION_INDEX=0
	_ZSH_AUTOSUGGEST_LAST_PREFIX="$BUFFER"

	_zsh_autosuggest_invoke_original_widget $@
}

# Modify the buffer and get a new suggestion
_zsh_autosuggest_modify() {
	local -i retval

	# Only available in zsh >= 5.4
	local -i KEYS_QUEUED_COUNT

	# Save the contents of the buffer/postdisplay
	local orig_buffer="$BUFFER"
	local orig_postdisplay="$POSTDISPLAY"

	# Clear suggestion while waiting for next one
	POSTDISPLAY=

	# Original widget may modify the buffer
	_zsh_autosuggest_invoke_original_widget $@
	retval=$?

	emulate -L zsh

	# Don't fetch a new suggestion if there's more input to be read immediately
	if (( $PENDING > 0 || $KEYS_QUEUED_COUNT > 0 )); then
		POSTDISPLAY="$orig_postdisplay"
		return $retval
	fi

	# Optimize if manually typing in the suggestion or if buffer hasn't changed
	if [[ "$BUFFER" = "$orig_buffer"* && "$orig_postdisplay" = "${BUFFER:$#orig_buffer}"* ]]; then
		POSTDISPLAY="${orig_postdisplay:$(($#BUFFER - $#orig_buffer))}"
		return $retval
	fi

	# Bail out if suggestions are disabled
	if (( ${+_ZSH_AUTOSUGGEST_DISABLED} )); then
		return $?
	fi

	# Get a new suggestion if the buffer is not empty after modification
	if (( $#BUFFER > 0 )); then
		if [[ -z "$ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE" ]] || (( $#BUFFER <= $ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE )); then
			_zsh_autosuggest_fetch
		fi
	fi

	return $retval
}

# Fetch a new suggestion based on what's currently in the buffer
_zsh_autosuggest_fetch() {
	local -i offset=${1:-0}
	local mode="${2:-auto}"
	local use_async=0

	# Reset offset if the buffer changed since the last suggestion lookup
	if [[ "$BUFFER" != "${_ZSH_AUTOSUGGEST_LAST_PREFIX-}" ]]; then
		offset=0
	fi

	if (( ${+ZSH_AUTOSUGGEST_USE_ASYNC} )); then
		use_async=1
	fi

	if [[ "$mode" == "sync" ]]; then
		use_async=0
		# Cancel any pending async request so results don't race the sync fetch
		_zsh_autosuggest_async_cancel
	fi

	_ZSH_AUTOSUGGEST_PENDING_OFFSET=$offset
	_ZSH_AUTOSUGGEST_PENDING_BUFFER="$BUFFER"

	if (( use_async )); then
		_zsh_autosuggest_async_request "$BUFFER" $offset
	else
		local suggestion
		_zsh_autosuggest_fetch_suggestion "$BUFFER" $offset

		if [[ -n "$suggestion" ]]; then
			_ZSH_AUTOSUGGEST_SUGGESTION_INDEX=$offset
			_ZSH_AUTOSUGGEST_LAST_PREFIX="$BUFFER"
		else
			if (( offset > 0 )); then
				_ZSH_AUTOSUGGEST_SUGGESTION_INDEX=0
			fi
			# Ensure state tracks the current buffer even when no suggestion exists
			_ZSH_AUTOSUGGEST_LAST_PREFIX="$BUFFER"
		fi

		_zsh_autosuggest_suggest "$suggestion"

		# Clear pending markers for synchronous flow
		unset _ZSH_AUTOSUGGEST_PENDING_BUFFER
		_ZSH_AUTOSUGGEST_PENDING_OFFSET=0
	fi
}

# Offer a suggestion
_zsh_autosuggest_suggest() {
	emulate -L zsh

	local suggestion="$1"

	if [[ -n "$suggestion" ]] && (( $#BUFFER )); then
		POSTDISPLAY="${suggestion#$BUFFER}"
	else
		POSTDISPLAY=
	fi
}

# Accept the entire suggestion
_zsh_autosuggest_accept() {
	local -i retval max_cursor_pos=$#BUFFER

	# When vicmd keymap is active, the cursor can't move all the way
	# to the end of the buffer
	if [[ "$KEYMAP" = "vicmd" ]]; then
		max_cursor_pos=$((max_cursor_pos - 1))
	fi

	# If we're not in a valid state to accept a suggestion, just run the
	# original widget and bail out
	if (( $CURSOR != $max_cursor_pos || !$#POSTDISPLAY )); then
		_zsh_autosuggest_invoke_original_widget $@
		return
	fi

	# Only accept if the cursor is at the end of the buffer
	# Add the suggestion to the buffer
	BUFFER="$BUFFER$POSTDISPLAY"

	# Remove the suggestion
	POSTDISPLAY=

	# Run the original widget before manually moving the cursor so that the
	# cursor movement doesn't make the widget do something unexpected
	_zsh_autosuggest_invoke_original_widget $@
	retval=$?

	# Move the cursor to the end of the buffer
	if [[ "$KEYMAP" = "vicmd" ]]; then
		CURSOR=$(($#BUFFER - 1))
	else
		CURSOR=$#BUFFER
	fi

	return $retval
}

# Accept the entire suggestion and execute it
_zsh_autosuggest_execute() {
	# Add the suggestion to the buffer
	BUFFER="$BUFFER$POSTDISPLAY"

	# Remove the suggestion
	POSTDISPLAY=

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

() {
	typeset -ga _ZSH_AUTOSUGGEST_BUILTIN_ACTIONS

	_ZSH_AUTOSUGGEST_BUILTIN_ACTIONS=(
		clear
		fetch
		suggest
		next
		previous
		accept
		execute
		enable
		disable
		toggle
	)

	local action
	for action in $_ZSH_AUTOSUGGEST_BUILTIN_ACTIONS modify partial_accept; do
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

	for action in $_ZSH_AUTOSUGGEST_BUILTIN_ACTIONS; do
		zle -N autosuggest-$action _zsh_autosuggest_widget_$action
	done
}
