# Color to use when highlighting autosuggestion
# Uses format of `region_highlight`
# More info: http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets
ZSH_AUTOSUGGEST_HIGHLIGHT_COLOR='fg=8'

# Widgets that clear the autosuggestion
ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(
	history-search-forward
	history-search-backward
	history-beginning-search-forward
	history-beginning-search-backward
	history-substring-search-up
	history-substring-search-down
	accept-line
)

# Widgets that modify the autosuggestion
ZSH_AUTOSUGGEST_MODIFY_WIDGETS=(
	complete-word
	expand-or-complete
	expand-or-complete-prefix
	list-choices
	menu-complete
	reverse-menu-complete
	menu-expand-or-complete
	accept-and-menu-complete
	self-insert
	magic-space
	backward-delete-char
	bracketed-paste
)

# Widgets that accept the autosuggestion
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
	vi-forward-char
	forward-char
)
