# Fish-like autosuggestions for zsh based on the code for 'predict-on'
#
# ```zsh
# zle-line-init() {
#		enable-autosuggestions
# }
# zle -N zle-line-init
# ```
zmodload zsh/net/socket

source "${0:a:h}/completion-client.zsh"

function {
	[[ -n $ZLE_DISABLE_AUTOSUGGEST ]] && return
	autosuggest-ensure-server
}

ZLE_AUTOSUGGEST_PAUSE_WIDGETS=(
vi-cmd-mode vi-backward-char backward-char backward-word beginning-of-line
history-search-forward history-search-backward up-line-or-history
down-line-or-history
)

ZLE_AUTOSUGGEST_COMPLETION_WIDGETS=(
complete-word expand-or-complete expand-or-complete-prefix list-choices
menu-complete reverse-menu-complete menu-expand-or-complete menu-select
accept-and-menu-complete
)

pause-autosuggestions() {
	[[ -n $ZLE_AUTOSUGGESTING_PAUSED ]] && return
	local widget
	# When autosuggestions are disabled, kill the unmaterialized part
	RBUFFER=''
	unset ZLE_AUTOSUGGESTING
	ZLE_AUTOSUGGESTING_PAUSED=1
	zle -A self-insert paused-autosuggest-self-insert
	zle -A .magic-space magic-space
	zle -A .backward-delete-char backward-delete-char
	zle -A .accept-line accept-line
	for widget in $ZLE_AUTOSUGGEST_PAUSE_WIDGETS; do
		eval "zle -A autosuggest-${widget}-orig ${widget}"
	done
	for widget in $ZLE_AUTOSUGGEST_COMPLETION_WIDGETS; do
		eval "zle -A autosuggest-${widget}-orig $widget"
	done
	highlight-suggested-text
}

enable-autosuggestions() {
	[[ -n $ZLE_AUTOSUGGESTING ]] && return
	local widget
	unset ZLE_AUTOSUGGESTING_PAUSED
	ZLE_AUTOSUGGESTING=1
	# Replace prediction widgets by versions that will also highlight RBUFFER
	zle -N self-insert autosuggest-self-insert
	zle -N magic-space autosuggest-self-insert
	zle -N backward-delete-char autosuggest-delete
	zle -N accept-line autosuggest-accept-line
	# Hook into some default widgets that should pause autosuggestion
	# automatically 
	for widget in $ZLE_AUTOSUGGEST_PAUSE_WIDGETS; do
		eval "zle -A $widget autosuggest-${widget}-orig; \
			zle -A autosuggest-pause $widget"
	done
	# Hook into completion widgets to handle suggestions after completions
	for widget in $ZLE_AUTOSUGGEST_COMPLETION_WIDGETS; do
		eval "zle -A $widget autosuggest-${widget}-orig; \
			zle -A autosuggest-tab $widget"
	done
	if [[ $BUFFER != '' ]]; then
		show-suggestion
	fi
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

# Taken from predict-on
autosuggest-delete() {
	if (( $#LBUFFER > 1 )); then
		setopt localoptions noshwordsplit noksharrays
		# When editing a multiline buffer, it's unlikely prediction is wanted;
		# or if the last widget was e.g. a motion, then probably the intent is
		# to actually edit the line, not change the search prefix.
		if [[ $LASTWIDGET != (self-insert|magic-space|backward-delete-char) ]]; then
			LBUFFER="$LBUFFER[1,-2]"
		else
			((--CURSOR))
			zle .history-beginning-search-forward || RBUFFER=""
			return 0
		fi
	else
		zle .kill-whole-line
	fi
	highlight-suggested-text
}

# When autosuggesting, ignore RBUFFER which corresponds to the 'unmaterialized'
# section when the user accepts the line
autosuggest-accept-line() {
	RBUFFER=''
	region_highlight=()
	zle .accept-line
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

autosuggest-get-completion() {
	local suggestion=$(autosuggest-first-completion $LBUFFER)
	RBUFFER="$suggestion"
}

show-suggestion() {
	[[ -n $ZLE_DISABLE_AUTOSUGGEST || $LBUFFER == '' ]] && return
	zle .history-beginning-search-backward || autosuggest-get-completion
	highlight-suggested-text
}

autosuggest-pause() {
	pause-autosuggestions
	zle autosuggest-${WIDGET}-orig "$@"
}

autosuggest-tab() {
	RBUFFER=''
	zle autosuggest-${WIDGET}-orig "$@"
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
zle -N accept-suggested-small-word
zle -N accept-suggested-word
zle -N autosuggest-pause
zle -N autosuggest-tab
