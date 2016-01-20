# Fish-like autosuggestions for zsh. Some of the code was based on the code
# for 'predict-on'
#
# ```zsh
# zle-line-init() {
#		autosuggest-enable
# }
# zle -N zle-line-init
# ```
zmodload zsh/net/socket

source "${0:a:h}/completion-client.zsh"

# configuration variables
AUTOSUGGESTION_HIGHLIGHT_COLOR='fg=8'
AUTOSUGGESTION_HIGHLIGHT_CURSOR=1

function {
	if [[ -n $ZLE_DISABLE_AUTOSUGGEST ]]; then
		ZSH_HIGHLIGHT_HIGHLIGHTERS=()
		return
	fi
	autoload -U is-at-least

	# if is-at-least 5.0.3; then
	# 	autosuggest-ensure-server
	# fi
}

ZLE_AUTOSUGGEST_SUSPEND_WIDGETS=(
	vi-cmd-mode vi-backward-char backward-char backward-word beginning-of-line
	history-search-forward history-search-backward up-line-or-history
	history-beginning-search-forward history-beginning-search-backward
	down-line-or-history history-substring-search-up history-substring-search-down
	backward-kill-word
)

ZLE_AUTOSUGGEST_COMPLETION_WIDGETS=(
	complete-word expand-or-complete expand-or-complete-prefix list-choices
	menu-complete reverse-menu-complete menu-expand-or-complete menu-select
	accept-and-menu-complete
)

ZLE_AUTOSUGGEST_ACCEPT_WIDGETS=(
	vi-forward-char forward-char vi-forward-word forward-word vi-add-eol
	vi-add-next vi-forward-blank-word vi-end-of-line end-of-line
)

ZLE_AUTOSUGGEST_ALL_WIDGETS=(
	self-insert magic-space backward-delete-char accept-line
	$ZLE_AUTOSUGGEST_ACCEPT_WIDGETS
	$ZLE_AUTOSUGGEST_SUSPEND_WIDGETS
	$ZLE_AUTOSUGGEST_COMPLETION_WIDGETS
)

autosuggest-pause() {
	[[ -z $ZLE_AUTOSUGGESTING ]] && return
	unset ZLE_AUTOSUGGESTING

	# Restore standard widgets except for self-insert, which triggers resume
	autosuggest-restore-widgets
	zle -A autosuggest-paused-self-insert self-insert

	# When autosuggestions are disabled, kill the unmaterialized part
	RBUFFER=''
	autosuggest-highlight-suggested-text

	if [[ -n $ZLE_AUTOSUGGEST_CONNECTION ]]; then
		zle -F $ZLE_AUTOSUGGEST_CONNECTION
	fi
}

autosuggest-resume() {
	[[ -n $ZLE_AUTOSUGGESTING ]] && return
	ZLE_AUTOSUGGESTING=1
	autosuggest-hook-widgets
	if [[ -n $ZLE_AUTOSUGGEST_CONNECTION ]]; then
		# install listen for suggestions asynchronously
		zle -Fw $ZLE_AUTOSUGGEST_CONNECTION autosuggest-pop-suggestion
	fi
}

autosuggest-start() {
	if [[ -z $ZLE_DISABLE_AUTOSUGGEST && -n $functions[_zsh_highlight] ]]; then
		if [[ ${ZSH_HIGHLIGHT_HIGHLIGHTERS[(i)autosuggest]} -gt ${#ZSH_HIGHLIGHT_HIGHLIGHTERS} ]]; then
			ZSH_HIGHLIGHT_HIGHLIGHTERS+=(autosuggest)
		fi
	fi
	autosuggest-resume
}

# Toggles autosuggestions on/off
autosuggest-toggle() {
	if [[ -n $ZLE_AUTOSUGGESTING ]]; then
		autosuggest-pause
		zle -A .self-insert self-insert
	else
		autosuggest-resume
	fi
}

autosuggest-highlight-suggested-text() {
	if (( $+functions[_zsh_highlight_buffer_modified] > 0 )); then
		_zsh_highlight
	else
		region_highlight=()
		_zsh_highlight_autosuggest_highlighter
	fi
}

_zsh_highlight_autosuggest_highlighter_predicate() {
	[[ -n $ZLE_AUTOSUGGESTING ]] && (( $#RBUFFER > 0 ))
}

_zsh_highlight_autosuggest_highlighter() {
	region_highlight+=("$(( $CURSOR + $AUTOSUGGESTION_HIGHLIGHT_CURSOR )) $(( $CURSOR + $#RBUFFER )) $AUTOSUGGESTION_HIGHLIGHT_COLOR")
}

autosuggest-insert-or-space() {
	setopt localoptions noshwordsplit noksharrays
	if [[ $LBUFFER == *$'\012'* ]] || (( PENDING )); then
		# Editing multiline buffer or pasting a chunk of text, pause
		autosuggest-suspend
		return
	fi

	if [[ ${RBUFFER[1]} == ${KEYS[-1]} ]]; then
		# Same as what's typed, just move on
		((++CURSOR))
		autosuggest-invalidate-highlight-cache
	else
		LBUFFER="$LBUFFER$KEYS"
		if [[ $LASTWIDGET == (self-insert|magic-space|backward-delete-char) || $LASTWIDGET == (complete-word|accept-*|zle-line-init) ]]; then
			if ! zle .history-beginning-search-backward; then
				RBUFFER=''
				if [[ ${KEYS[-1]} != ' ' ]]; then
					autosuggest-send-request ${LBUFFER}
				fi
			fi
		fi
	fi
	autosuggest-highlight-suggested-text
}

autosuggest-backward-delete-char() {
	if (( $#LBUFFER > 1 )); then
		setopt localoptions noshwordsplit noksharrays

		if [[ $LBUFFER = *$'\012'* || $LASTWIDGET != (self-insert|magic-space|backward-delete-char) ]]; then
			LBUFFER="$LBUFFER[1,-2]"
		else
			((--CURSOR))
			autosuggest-invalidate-highlight-cache
			zle .history-beginning-search-forward || RBUFFER=''
		fi
		autosuggest-highlight-suggested-text
	else
		zle .kill-whole-line
	fi
}

# When autosuggesting, ignore RBUFFER which corresponds to the 'unmaterialized'
# section when the user accepts the line
autosuggest-accept-line() {
	RBUFFER=''
	if ! (( $+functions[_zsh_highlight_buffer_modified] )); then
		# Only clear the colors if the user doesn't have zsh-highlight installed
		region_highlight=()
	fi
	zle .accept-line
}

autosuggest-paused-self-insert() {
	if [[ $RBUFFER == '' ]]; then
		# Resume autosuggestions when inserting at the end of the line
		autosuggest-resume
		zle self-insert
	else
		zle .self-insert
	fi
}

autosuggest-pop-suggestion() {
	local words last_word suggestion
	if ! IFS= read -r -u $ZLE_AUTOSUGGEST_CONNECTION suggestion; then
		# server closed the connection, stop listenting
		zle -F $ZLE_AUTOSUGGEST_CONNECTION
		unset ZLE_AUTOSUGGEST_CONNECTION
		return
	fi
	if [[ -n $suggestion ]]; then
		local prefix=${suggestion%$'\2'*}
		suggestion=${suggestion#*$'\2'}
		# only use the suggestion if the prefix is still compatible with
		# the suggestion(prefix should be contained in LBUFFER)
		if [[ ${LBUFFER#$prefix*} != ${LBUFFER} ]]; then
			words=(${(z)LBUFFER})
			last_word=${words[-1]}
			suggestion=${suggestion:$#last_word}
			RBUFFER="$suggestion"
			autosuggest-highlight-suggested-text
		else
			RBUFFER=''
		fi
	else
		RBUFFER=''
	fi
	zle -Rc
}

autosuggest-suspend() {
	autosuggest-pause
	zle .${WIDGET} "$@"
}

autosuggest-tab() {
	RBUFFER=''
	zle .${WIDGET} "$@"
	autosuggest-invalidate-highlight-cache
	autosuggest-highlight-suggested-text
}

autosuggest-accept-suggestion() {
	if [[ AUTOSUGGESTION_ACCEPT_RIGHT_ARROW -eq 1 && ("$WIDGET" == 'forward-char' || "$WIDGET" == 'vi-forward-char') ]]; then
		zle .end-of-line "$@"
	else
		zle .${WIDGET} "$@"
	fi
	if [[ -n $ZLE_AUTOSUGGESTING ]]; then
		autosuggest-invalidate-highlight-cache
		autosuggest-highlight-suggested-text
	fi
}

autosuggest-execute-suggestion() {
	if [[ -n $ZLE_AUTOSUGGESTING ]]; then
		zle .end-of-line
		autosuggest-invalidate-highlight-cache
		autosuggest-highlight-suggested-text
	fi
	zle .accept-line
}

autosuggest-invalidate-highlight-cache() {
	# invalidate the buffer for zsh-syntax-highlighting
	_zsh_highlight_autosuggest_highlighter_cache=()
}

autosuggest-restore-widgets() {
	for widget in $ZLE_AUTOSUGGEST_ALL_WIDGETS; do
		[[ -z $widgets[$widget] ]] && continue
		zle -A .${widget} ${widget}
	done
}

autosuggest-hook-widgets() {
	local widget
	# Replace prediction widgets by versions that will also highlight RBUFFER
	zle -A autosuggest-insert-or-space      self-insert
	zle -A autosuggest-insert-or-space      magic-space
	zle -A autosuggest-backward-delete-char backward-delete-char
	zle -A autosuggest-accept-line          accept-line
	# Hook into some default widgets that should suspend autosuggestion
	# automatically
	for widget in $ZLE_AUTOSUGGEST_ACCEPT_WIDGETS; do
		[[ -z $widgets[$widget] ]] && continue
		eval "zle -A autosuggest-accept-suggestion $widget"
	done
	for widget in $ZLE_AUTOSUGGEST_SUSPEND_WIDGETS; do
		[[ -z $widgets[$widget] ]] && continue
		eval "zle -A autosuggest-suspend $widget"
	done
	for widget in $ZLE_AUTOSUGGEST_COMPLETION_WIDGETS; do
		[[ -z $widgets[$widget] ]] && continue
		eval "zle -A autosuggest-tab $widget"
	done
}

zle -N autosuggest-toggle
zle -N autosuggest-start
zle -N autosuggest-accept-suggested-small-word
zle -N autosuggest-accept-suggested-word
zle -N autosuggest-execute-suggestion

zle -N autosuggest-paused-self-insert
zle -N autosuggest-insert-or-space
zle -N autosuggest-backward-delete-char
zle -N autosuggest-accept-line

zle -N autosuggest-tab
zle -N autosuggest-suspend
zle -N autosuggest-accept-suggestion

autosuggest-restore-widgets
