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
#
zstyle -t ':predict' verbose || zstyle ':predict' verbose no
zstyle -t ':completion:predict:*' completer || zstyle ':completion:predict:*' completer _expand _complete

autoload predict-on

pause-autosuggestions() {
	# When autosuggestions are disabled, kill the unmaterialized part
	RBUFFER=''
	unset ZLE_AUTOSUGGESTING
	ZLE_AUTOSUGGESTING_PAUSED=1
	predict-off
	zle -A self-insert paused-autosuggest-self-insert
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
	highlight-suggested-text
}

enable-autosuggestions() {
	unset ZLE_AUTOSUGGESTING_PAUSED
	ZLE_AUTOSUGGESTING=1
	predict-on
	# Save the prediction widgets
	zle -A self-insert insert-and-predict-orig
	zle -A backward-delete-char delete-backward-and-predict-orig
	zle -A delete-char-or-list delete-no-predict-orig
	# Replace prediction widgets by versions that will also highlight RBUFFER
	zle -A autosuggest-self-insert self-insert
	zle -A autosuggest-self-insert magic-space
	zle -A autosuggest-backward-delete-char backward-delete-char
	zle -A autosuggest-delete-char-or-list delete-char-or-list 
	# Replace some default widgets that should disable autosuggestion
	# automatically 
	zle -A autosuggest-accept-line accept-line
	zle -A autosuggest-vi-cmd-mode vi-cmd-mode
	zle -A autosuggest-vi-backward-char vi-backward-char
	zle -A autosuggest-backward-char backward-char
	zle -A autosuggest-backward-word backward-word
	zle -A autosuggest-beginning-of-line beginning-of-line
	zle -A autosuggest-history-search-forward history-search-forward
	zle -A autosuggest-history-search-backward history-search-backward
	zle -A autosuggest-up-line-or-history up-line-or-history
	zle -A autosuggest-down-line-or-history down-line-or-history
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

# When entering vi command mode, disable autosuggestions as its possible the
# user is going to edit the middle of the line
autosuggest-vi-cmd-mode() {
	pause-autosuggestions
	zle .vi-cmd-mode
}

# Disable autosuggestions when doing anything that moves the cursor to the left
autosuggest-vi-backward-char() {
	pause-autosuggestions
	zle .vi-backward-char
}

autosuggest-backward-char() {
	pause-autosuggestions
	zle .backward-char
}

autosuggest-backward-word() {
	pause-autosuggestions
	zle .backward-word
}

autosuggest-beginning-of-line() {
	pause-autosuggestions
	zle .beginning-of-line
}

# Searching history or moving arrows up/down also disables autosuggestion
autosuggest-history-search-forward() {
	pause-autosuggestions
	zle .history-search-forward
}

autosuggest-history-search-backward() {
	pause-autosuggestions
	zle .history-search-backward
}

autosuggest-up-line-or-history() {
	pause-autosuggestions
	zle .up-line-or-history
}

autosuggest-down-line-or-history() {
	pause-autosuggestions
	zle .down-line-or-history
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
		insert-and-autosuggest
	else
		zle .self-insert
	fi
}

autosuggest-self-insert() {
	zle insert-and-predict-orig
	highlight-suggested-text
}

autosuggest-backward-delete-char() {
	zle delete-backward-and-predict-orig
	highlight-suggested-text
}

autosuggest-delete-char-or-list() {
	zle delete-no-predict-orig
	highlight-suggested-text
}

zle -N toggle-autosuggestions
zle -N enable-autosuggestions
zle -N disable-autosuggestions
zle -N paused-autosuggest-self-insert
zle -N autosuggest-self-insert
zle -N autosuggest-backward-delete-char
zle -N autosuggest-delete-char-or-list
zle -N autosuggest-accept-line
zle -N autosuggest-vi-cmd-mode
zle -N autosuggest-vi-backward-char
zle -N autosuggest-backward-char
zle -N autosuggest-backward-word
zle -N autosuggest-beginning-of-line
zle -N autosuggest-history-search-forward
zle -N autosuggest-history-search-backward
zle -N autosuggest-up-line-or-history
zle -N autosuggest-down-line-or-history
