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
zstyle ':predict' verbose no
zstyle ':completion:predict:*' completer _complete

autoload predict-on

pause-autosuggestions() {
	# When autosuggestions are disabled, kill the unmaterialized part
	RBUFFER=''
	unset ZLE_AUTOSUGGESTING
	ZLE_AUTOSUGGESTING_PAUSED=1
	predict-off
	zle -N self-insert paused-autosuggest-self-insert
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
	zle -A .expand-or-complete expand-or-complete
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
	zle -N self-insert insert-and-autosuggest
	zle -N magic-space insert-and-autosuggest
	zle -N backward-delete-char delete-backward-and-autosuggest
	zle -N delete-char-or-list delete-no-autosuggest
	# Replace some default widgets that should disable autosuggestion
	# automatically 
	zle -N accept-line autosuggest-accept-line
	zle -N vi-cmd-mode autosuggest-vi-cmd-mode
	zle -N vi-backward-char autosuggest-vi-backward-char
	zle -N backward-char autosuggest-backward-char
	zle -N backward-word autosuggest-backward-word
	zle -N beginning-of-line autosuggest-beginning-of-line
	zle -N history-search-forward autosuggest-history-search-forward
	zle -N history-search-backward autosuggest-history-search-backward
	zle -N up-line-or-history autosuggest-up-line-or-history
	zle -N down-line-or-history autosuggest-down-line-or-history
	zle -N expand-or-complete autosuggest-expand-or-complete
	if [[ $BUFFER != '' ]]; then
		local cursor=$CURSOR
		zle complete-word
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

paused-autosuggest-self-insert() {
	if [[ $RBUFFER == '' ]]; then
		# Resume autosuggestions when inserting at the end of the line
		enable-autosuggestions
		zle insert-and-autosuggest
	else
		zle .self-insert
	fi
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

insert-and-autosuggest() {
	zle insert-and-predict-orig
	highlight-suggested-text
}

autosuggest-expand-or-complete() {
	if [[ $RBUFFER == '' ]]; then
		# If predict-on didnt insert anything, do a normal word
		# expansion/completion
		zle expand-or-complete-prefix
		region_highlight=()
	else
		# Else advance the current big word
		zle .vi-forward-blank-word
		highlight-suggested-text
	fi
}

delete-backward-and-autosuggest() {
	zle delete-backward-and-predict-orig
	highlight-suggested-text
}

delete-no-autosuggest() {
	zle delete-no-predict-orig
	highlight-suggested-text
}

zle -N enable-autosuggestions
zle -N disable-autosuggestions
zle -N toggle-autosuggestions
zle -N autosuggest-accept-line
zle -N autosuggest-vi-cmd-mode
zle -N autosuggest-history-search-forward
zle -N autosuggest-history-search-backward
zle -N autosuggest-up-line-or-history
zle -N autosuggest-down-line-or-history
zle -N autosuggest-expand-or-complete
zle -N insert-and-autosuggest
zle -N delete-backward-and-autosuggest
zle -N delete-no-autosuggest
