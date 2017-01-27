# Fish-like fast/unobtrusive autosuggestions for zsh.
# https://github.com/zsh-users/zsh-autosuggestions
# v0.3.3
# Copyright (c) 2013 Thiago de Arruda
# Copyright (c) 2016 Eric Freese
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

#--------------------------------------------------------------------#
# Setup                                                              #
#--------------------------------------------------------------------#

# Precmd hooks for initializing the library and starting pty's
autoload -Uz add-zsh-hook

# Asynchronous suggestions are generated in a pty
zmodload zsh/zpty

#--------------------------------------------------------------------#
# Global Configuration Variables                                     #
#--------------------------------------------------------------------#

# Color to use when highlighting suggestion
# Uses format of `region_highlight`
# More info: http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Prefix to use when saving original versions of bound widgets
ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX=autosuggest-orig-

# Pty name for calculating autosuggestions asynchronously
ZSH_AUTOSUGGEST_PTY_NAME=zsh_autosuggest_pty

ZSH_AUTOSUGGEST_STRATEGY=default

# Widgets that clear the suggestion
ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(
	history-search-forward
	history-search-backward
	history-beginning-search-forward
	history-beginning-search-backward
	history-substring-search-up
	history-substring-search-down
	up-line-or-history
	down-line-or-history
	accept-line
)

# Widgets that accept the entire suggestion
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
	forward-char
	end-of-line
	vi-forward-char
	vi-end-of-line
	vi-add-eol
)

# Widgets that accept the entire suggestion and execute it
ZSH_AUTOSUGGEST_EXECUTE_WIDGETS=(
)

# Widgets that accept the suggestion as far as the cursor moves
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
	forward-word
	vi-forward-word
	vi-forward-word-end
	vi-forward-blank-word
	vi-forward-blank-word-end
)

# Widgets that should be ignored (globbing supported but must be escaped)
ZSH_AUTOSUGGEST_IGNORE_WIDGETS=(
	orig-\*
	beep
	run-help
	set-local-history
	which-command
	yank
)

# Max size of buffer to trigger autosuggestion. Leave undefined for no upper bound.
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=

# Use asynchronous mode by default. Unset this variable to use sync mode.
ZSH_AUTOSUGGEST_USE_ASYNC=

#--------------------------------------------------------------------#
# Utility Functions                                                  #
#--------------------------------------------------------------------#

_zsh_autosuggest_escape_command() {
	setopt localoptions EXTENDED_GLOB

	# Escape special chars in the string (requires EXTENDED_GLOB)
	echo -E "${1//(#m)[\"\'\\()\[\]|*?~]/\\$MATCH}"
}

#--------------------------------------------------------------------#
# Feature Detection                                                  #
#--------------------------------------------------------------------#

_zsh_autosuggest_feature_detect() {
	typeset -g _ZSH_AUTOSUGGEST_ZPTY_RETURNS_FD
	typeset -h REPLY

	zpty $ZSH_AUTOSUGGEST_PTY_NAME :

	if (( REPLY )); then
		_ZSH_AUTOSUGGEST_ZPTY_RETURNS_FD=1
	else
		_ZSH_AUTOSUGGEST_ZPTY_RETURNS_FD=0
	fi

	zpty -d $ZSH_AUTOSUGGEST_PTY_NAME
}

#--------------------------------------------------------------------#
# Handle Deprecated Variables/Widgets                                #
#--------------------------------------------------------------------#

_zsh_autosuggest_deprecated_warning() {
	>&2 echo "zsh-autosuggestions: $@"
}

_zsh_autosuggest_check_deprecated_config() {
	if [ -n "$AUTOSUGGESTION_HIGHLIGHT_COLOR" ]; then
		_zsh_autosuggest_deprecated_warning "AUTOSUGGESTION_HIGHLIGHT_COLOR is deprecated. Use ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE instead."
		[ -z "$ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" ] && ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=$AUTOSUGGESTION_HIGHLIGHT_STYLE
		unset AUTOSUGGESTION_HIGHLIGHT_STYLE
	fi

	if [ -n "$AUTOSUGGESTION_HIGHLIGHT_CURSOR" ]; then
		_zsh_autosuggest_deprecated_warning "AUTOSUGGESTION_HIGHLIGHT_CURSOR is deprecated."
		unset AUTOSUGGESTION_HIGHLIGHT_CURSOR
	fi

	if [ -n "$AUTOSUGGESTION_ACCEPT_RIGHT_ARROW" ]; then
		_zsh_autosuggest_deprecated_warning "AUTOSUGGESTION_ACCEPT_RIGHT_ARROW is deprecated. The right arrow now accepts the suggestion by default."
		unset AUTOSUGGESTION_ACCEPT_RIGHT_ARROW
	fi
}

_zsh_autosuggest_deprecated_start_widget() {
	_zsh_autosuggest_deprecated_warning "The autosuggest-start widget is deprecated. For more info, see the README at https://github.com/zsh-users/zsh-autosuggestions."
	zle -D autosuggest-start
	eval "zle-line-init() {
		$(echo $functions[${widgets[zle-line-init]#*:}] | sed -e 's/zle autosuggest-start//g')
	}"
}

zle -N autosuggest-start _zsh_autosuggest_deprecated_start_widget

#--------------------------------------------------------------------#
# Widget Helpers                                                     #
#--------------------------------------------------------------------#

# Bind a single widget to an autosuggest widget, saving a reference to the original widget
_zsh_autosuggest_bind_widget() {
	local widget=$1
	local autosuggest_action=$2
	local prefix=$ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX

	# Save a reference to the original widget
	case $widgets[$widget] in
		# Already bound
		user:_zsh_autosuggest_(bound|orig)_*);;

		# User-defined widget
		user:*)
			zle -N $prefix$widget ${widgets[$widget]#*:}
			;;

		# Built-in widget
		builtin)
			eval "_zsh_autosuggest_orig_${(q)widget}() { zle .${(q)widget} }"
			zle -N $prefix$widget _zsh_autosuggest_orig_$widget
			;;

		# Completion widget
		completion:*)
			eval "zle -C $prefix${(q)widget} ${${(s.:.)widgets[$widget]}[2,3]}"
			;;
	esac

	# Pass the original widget's name explicitly into the autosuggest
	# function. Use this passed in widget name to call the original
	# widget instead of relying on the $WIDGET variable being set
	# correctly. $WIDGET cannot be trusted because other plugins call
	# zle without the `-w` flag (e.g. `zle self-insert` instead of
	# `zle self-insert -w`).
	eval "_zsh_autosuggest_bound_${(q)widget}() {
		_zsh_autosuggest_widget_$autosuggest_action $prefix${(q)widget} \$@
	}"

	# Create the bound widget
	zle -N $widget _zsh_autosuggest_bound_$widget
}

# Map all configured widgets to the right autosuggest widgets
_zsh_autosuggest_bind_widgets() {
	local widget
	local ignore_widgets

	ignore_widgets=(
		.\*
		_\*
		zle-line-\*
		autosuggest-\*
		$ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX\*
		$ZSH_AUTOSUGGEST_IGNORE_WIDGETS
	)

	# Find every widget we might want to bind and bind it appropriately
	for widget in ${${(f)"$(builtin zle -la)"}:#${(j:|:)~ignore_widgets}}; do
		if [ ${ZSH_AUTOSUGGEST_CLEAR_WIDGETS[(r)$widget]} ]; then
			_zsh_autosuggest_bind_widget $widget clear
		elif [ ${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[(r)$widget]} ]; then
			_zsh_autosuggest_bind_widget $widget accept
		elif [ ${ZSH_AUTOSUGGEST_EXECUTE_WIDGETS[(r)$widget]} ]; then
			_zsh_autosuggest_bind_widget $widget execute
		elif [ ${ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS[(r)$widget]} ]; then
			_zsh_autosuggest_bind_widget $widget partial_accept
		else
			# Assume any unspecified widget might modify the buffer
			_zsh_autosuggest_bind_widget $widget modify
		fi
	done
}

# Given the name of an original widget and args, invoke it, if it exists
_zsh_autosuggest_invoke_original_widget() {
	# Do nothing unless called with at least one arg
	[ $# -gt 0 ] || return

	local original_widget_name="$1"

	shift

	if [ $widgets[$original_widget_name] ]; then
		zle $original_widget_name -- $@
	fi
}

#--------------------------------------------------------------------#
# Highlighting                                                       #
#--------------------------------------------------------------------#

# If there was a highlight, remove it
_zsh_autosuggest_highlight_reset() {
	typeset -g _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT

	if [ -n "$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT" ]; then
		region_highlight=("${(@)region_highlight:#$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT}")
		unset _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT
	fi
}

# If there's a suggestion, highlight it
_zsh_autosuggest_highlight_apply() {
	typeset -g _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT

	if [ $#POSTDISPLAY -gt 0 ]; then
		_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT="$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) $ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
		region_highlight+=("$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT")
	else
		unset _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT
	fi
}

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

	# Clear suggestion while waiting for next one
	unset POSTDISPLAY

	# Original widget may modify the buffer
	_zsh_autosuggest_invoke_original_widget $@
	retval=$?

	# Optimize if manually typing in the suggestion
	if [ $#BUFFER -gt $#orig_buffer ]; then
		local added=${BUFFER#$orig_buffer}

		# If the string added matches the beginning of the postdisplay
		if [ "$added" = "${orig_postdisplay:0:$#added}" ]; then
			POSTDISPLAY="${orig_postdisplay:$#added}"
			return $retval
		fi
	fi

	# Don't fetch a new suggestion if the buffer hasn't changed
	if [ "$BUFFER" = "$orig_buffer" ]; then
		POSTDISPLAY="$orig_postdisplay"
		return $retval
	fi

	# Get a new suggestion if the buffer is not empty after modification
	if [ $#BUFFER -gt 0 ]; then
		if [ -z "$ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE" -o $#BUFFER -lt "$ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE" ]; then
			_zsh_autosuggest_fetch
		fi
	fi

	return $retval
}

# Fetch a new suggestion based on what's currently in the buffer
_zsh_autosuggest_fetch() {
	if zpty -t "$ZSH_AUTOSUGGEST_PTY_NAME" &>/dev/null; then
		_zsh_autosuggest_async_request "$BUFFER"
	else
		local suggestion
		_zsh_autosuggest_strategy_$ZSH_AUTOSUGGEST_STRATEGY "$BUFFER"
		_zsh_autosuggest_suggest "$suggestion"
	fi
}

# Offer a suggestion
_zsh_autosuggest_suggest() {
	local suggestion="$1"

	if [ -n "$suggestion" ]; then
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

for action in clear modify fetch suggest accept partial_accept execute; do
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

zle -N autosuggest-fetch _zsh_autosuggest_widget_fetch
zle -N autosuggest-suggest _zsh_autosuggest_widget_suggest
zle -N autosuggest-accept _zsh_autosuggest_widget_accept
zle -N autosuggest-clear _zsh_autosuggest_widget_clear
zle -N autosuggest-execute _zsh_autosuggest_widget_execute

#--------------------------------------------------------------------#
# Default Suggestion Strategy                                        #
#--------------------------------------------------------------------#
# Suggests the most recent history item that matches the given
# prefix.
#

_zsh_autosuggest_strategy_default() {
	setopt localoptions EXTENDED_GLOB

	local prefix="${1//(#m)[\\()\[\]|*?~]/\\$MATCH}"

	# Get the keys of the history items that match
	local -a histkeys
	histkeys=(${(k)history[(r)$prefix*]})

	# Give back the value of the first key
	suggestion="${history[$histkeys[1]]}"
}

#--------------------------------------------------------------------#
# Match Previous Command Suggestion Strategy                         #
#--------------------------------------------------------------------#
# Suggests the most recent history item that matches the given
# prefix and whose preceding history item also matches the most
# recently executed command.
#
# For example, suppose your history has the following entries:
#   - pwd
#   - ls foo
#   - ls bar
#   - pwd
#
# Given the history list above, when you type 'ls', the suggestion
# will be 'ls foo' rather than 'ls bar' because your most recently
# executed command (pwd) was previously followed by 'ls foo'.
#
# Note that this strategy won't work as expected with ZSH options that don't
# preserve the history order such as `HIST_IGNORE_ALL_DUPS` or
# `HIST_EXPIRE_DUPS_FIRST`.

_zsh_autosuggest_strategy_match_prev_cmd() {
	local prefix="${1//(#m)[\\()\[\]|*?~]/\\$MATCH}"

	# Get all history event numbers that correspond to history
	# entries that match pattern $prefix*
	local history_match_keys
	history_match_keys=(${(k)history[(R)$prefix*]})

	# By default we use the first history number (most recent history entry)
	local histkey="${history_match_keys[1]}"

	# Get the previously executed command
	local prev_cmd="$(_zsh_autosuggest_escape_command "${history[$((HISTCMD-1))]}")"

	# Iterate up to the first 200 history event numbers that match $prefix
	for key in "${(@)history_match_keys[1,200]}"; do
		# Stop if we ran out of history
		[[ $key -gt 1 ]] || break

		# See if the history entry preceding the suggestion matches the
		# previous command, and use it if it does
		if [[ "${history[$((key - 1))]}" == "$prev_cmd" ]]; then
			histkey="$key"
			break
		fi
	done

	# Give back the matched history entry
	suggestion="$history[$histkey]"
}

#--------------------------------------------------------------------#
# Async                                                              #
#--------------------------------------------------------------------#

# Pty is spawned running this function
_zsh_autosuggest_async_server() {
	emulate -R zsh

	# Output only newlines (not carriage return + newline)
	stty -onlcr

	local strategy=$1
	local last_pid

	while IFS='' read -r -d $'\0' query; do
		# Kill last bg process
		kill -KILL $last_pid &>/dev/null

		# Run suggestion search in the background
		(
			local suggestion
			_zsh_autosuggest_strategy_$ZSH_AUTOSUGGEST_STRATEGY "$query"
			echo -n -E "$suggestion"$'\0'
		) &

		last_pid=$!
	done
}

_zsh_autosuggest_async_request() {
	# Send the query to the pty to fetch a suggestion
	zpty -w -n $ZSH_AUTOSUGGEST_PTY_NAME "${1}"$'\0'
}

# Called when new data is ready to be read from the pty
# First arg will be fd ready for reading
# Second arg will be passed in case of error
_zsh_autosuggest_async_response() {
	local suggestion

	zpty -rt $ZSH_AUTOSUGGEST_PTY_NAME suggestion '*'$'\0' 2>/dev/null
	zle autosuggest-suggest "${suggestion%$'\0'}"
}

_zsh_autosuggest_async_pty_create() {
	# With newer versions of zsh, REPLY stores the fd to read from
	typeset -h REPLY

	# If we won't get a fd back from zpty, try to guess it
	if [ $_ZSH_AUTOSUGGEST_ZPTY_RETURNS_FD -eq 0 ]; then
		integer -l zptyfd
		exec {zptyfd}>&1  # Open a new file descriptor (above 10).
		exec {zptyfd}>&-  # Close it so it's free to be used by zpty.
	fi

	# Start a new pty running the server function
	zpty -b $ZSH_AUTOSUGGEST_PTY_NAME "_zsh_autosuggest_async_server _zsh_autosuggest_strategy_$ZSH_AUTOSUGGEST_STRATEGY"

	# Store the fd so we can remove the handler later
	if (( REPLY )); then
		_ZSH_AUTOSUGGEST_PTY_FD=$REPLY
	else
		_ZSH_AUTOSUGGEST_PTY_FD=$zptyfd
	fi

	# Set up input handler from the pty
	zle -F $_ZSH_AUTOSUGGEST_PTY_FD _zsh_autosuggest_async_response
}

_zsh_autosuggest_async_pty_destroy() {
	if [ -n "$_ZSH_AUTOSUGGEST_PTY_FD" ]; then
		# Remove the input handler
		zle -F $_ZSH_AUTOSUGGEST_PTY_FD

		# Destroy the pty
		zpty -d $ZSH_AUTOSUGGEST_PTY_NAME &>/dev/null
	fi
}

_zsh_autosuggest_async_pty_recreate() {
	_zsh_autosuggest_async_pty_destroy
	_zsh_autosuggest_async_pty_create
}

_zsh_autosuggest_async_start() {
	typeset -g _ZSH_AUTOSUGGEST_PTY_FD

	_zsh_autosuggest_async_pty_create

	# We recreate the pty to get a fresh list of history events
	add-zsh-hook precmd _zsh_autosuggest_async_pty_recreate
}

#--------------------------------------------------------------------#
# Start                                                              #
#--------------------------------------------------------------------#

# Start the autosuggestion widgets
_zsh_autosuggest_start() {
	add-zsh-hook -d precmd _zsh_autosuggest_start

	_zsh_autosuggest_feature_detect
	_zsh_autosuggest_check_deprecated_config
	_zsh_autosuggest_bind_widgets

	if [ -n "${ZSH_AUTOSUGGEST_USE_ASYNC+x}" ]; then
		_zsh_autosuggest_async_start
	fi
}

# Start the autosuggestion widgets on the next precmd
add-zsh-hook precmd _zsh_autosuggest_start
