# Fish-like autosuggestions for zsh. This is implemented on top of zsh's
# builtin prediction feature by treating whatever is after the cursor
# as 'unmaterialized'. The unmaterialized part is highlighted and ignored
# when the user accepts the line. To materialize autosuggestions 'TAB' must
# be pressed.
#
# Since predict-on doesn't work well on the middle of the line, many actions
# that move the cursor to the left will pause autosuggestions, so it should be
# safe enough to leave autosuggest enabled by default by adding the followingto
# zshrc:
#
# ```zsh
# zle-line-init() {
#		enable-autosuggestions
# }
# zle -N zle-line-init
# ```


pause-autosuggestions() {
	# When autosuggestions are disabled, kill the unmaterialized part
	RBUFFER=''
	unset ZLE_AUTOSUGGESTING
	ZLE_AUTOSUGGESTING_PAUSED=1
	zle -A self-insert paused-autosuggest-self-insert
	zle -A .magic-space magic-space
	zle -A .backward-delete-char backward-delete-char
	zle -A .delete-char-or-list delete-char-or-list
	zle -A .accept-line accept-line
	zle -A .vi-cmd-mode vi-cmd-mode
	zle -A .vi-backward-char vi-backward-char
	zle -A .backward-char backward-char
	zle -A .backward-word backward-word
	zle -A .beginning-of-line beginning-of-line
	zle -A .history-search-forward history-search-forward
	zle -A .history-search-backward history-search-backward
	zle -A .up-line-or-history up-line-or-history
	zle -A .down-line-or-history down-line-or-history
	zle -A .complete-word complete-word
	zle -A .expand-or-complete expand-or-complete
	highlight-suggested-text
}

enable-autosuggestions() {
	unset ZLE_AUTOSUGGESTING_PAUSED
	ZLE_AUTOSUGGESTING=1
	# Replace prediction widgets by versions that will also highlight RBUFFER
	zle -N self-insert autosuggest-self-insert
	zle -N self-insert autosuggest-self-insert
	zle -N backward-delete-char autosuggest-delete
	zle -N delete-char-or-list autosuggest-delete
	# Replace some default widgets that should disable autosuggestion
	# automatically 
	zle -N accept-line execute-widget-and-pause
	zle -N vi-cmd-mode execute-widget-and-pause
	zle -N vi-backward-char execute-widget-and-pause
	zle -N backward-char execute-widget-and-pause
	zle -N backward-word execute-widget-and-pause
	zle -N beginning-of-line execute-widget-and-pause
	zle -N history-search-forward execute-widget-and-pause
	zle -N history-search-backward execute-widget-and-pause
	zle -N up-line-or-history execute-widget-and-pause
	zle -N down-line-or-history execute-widget-and-pause
	zle -N complete-word autosuggest-expand-or-complete
	zle -N expand-or-complete autosuggest-expand-or-complete
	if [[ $BUFFER != '' ]]; then
		local cursor=$CURSOR
		zle .expand-or-complete
		CURSOR=$cursor
	fi
	highlight-suggested-text
}

disable-autosuggestions() {
	if [[ -z $ZLE_AUTOSUGGESTING_PAUSED ]]; then
		pause-autosuggestions
	fi
	unset ZLE_AUTOSUGGESTING_PAUSED
	zle -A .self-insert self-insert
}

# Toggles autosuggestions on/off
toggle-autosuggestions() {
	if [[ -n $ZLE_AUTOSUGGESTING || -n $ZLE_AUTOSUGGESTING_PAUSED ]]; then
		disable-autosuggestions
	else
		enable-autosuggestions
	fi
}

# TODO Most of the widgets here only override default widgets to disable
# autosuggestion, find a way to do it in a loop for the sake of maintainability

# When autosuggesting, ignore RBUFFER which corresponds to the 'unmaterialized'
# section when the user accepts the line
autosuggest-accept-line() {
	RBUFFER=''
	region_highlight=()
	zle .accept-line
}

execute-widget-and-pause() {
	pause-autosuggestions
	zle .$WIDGET "$@"
}

highlight-suggested-text() {
	if [[ -n $ZLE_AUTOSUGGESTING ]]; then
		local color='fg=8'
		[[ -n $AUTOSUGGESTION_HIGHLIGHT_COLOR ]] &&\
		 	color=$AUTOSUGGESTION_HIGHLIGHT_COLOR
		region_highlight=("$(( $CURSOR + 1 )) $(( $CURSOR + $#RBUFFER )) $color")
	else
		region_highlight=()
	fi
}

paused-autosuggest-self-insert() {
	if [[ $RBUFFER == '' ]]; then
		# Resume autosuggestions when inserting at the end of the line
		enable-autosuggestions
		autosuggest-self-insert
	else
		zle .self-insert
	fi
}

show-suggestion() {
	local complete_word=$1
	if ! zle .history-beginning-search-backward; then
		RBUFFER=''
		if [[ $LBUFFER[-1] != ' ' ]]; then
			integer curs=$CURSOR
			unsetopt automenu recexact
			zle complete-word-orig
			CURSOR=$curs
		fi
	fi
	highlight-suggested-text
}

autosuggest-self-insert() {
	setopt localoptions noshwordsplit noksharrays
	if [[ ${RBUFFER[1]} == ${KEYS[-1]} ]]; then
		# Same as what's typed, just move on
		((++CURSOR))
		highlight-suggested-text
	else
		LBUFFER="$LBUFFER$KEYS"
		show-suggestion
	fi
}

autosuggest-delete() {
	zle .$WIDGET
	show-suggestion
}

autosuggest-expand-or-complete() {
	RBUFFER=''
	zle .$WIDGET "$@"
	show-suggestion
}

accept-suggested-small-word() {
	zle .vi-forward-word
	highlight-suggested-text
}

accept-suggested-word() {
	zle .forward-word
	highlight-suggested-text
}

zle -N toggle-autosuggestions
zle -N enable-autosuggestions
zle -N disable-autosuggestions
zle -N accept-suggested-small-word
zle -N accept-suggested-word
