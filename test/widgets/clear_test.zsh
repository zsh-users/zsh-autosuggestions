#!/usr/bin/env zsh

source "${0:a:h}/../test_helper.zsh"

oneTimeSetUp() {
	source_autosuggestions
}

testClear() {
	BUFFER='ec'
	POSTDISPLAY='ho hello'

	_zsh_autosuggest_clear 'original-widget'

	assertEquals \
		'BUFFER was modified' \
		'ec' \
		"$BUFFER"

	assertNull \
		'POSTDISPLAY was not cleared' \
		"$POSTDISPLAY"
}

testWidget() {
	stub _zsh_autosuggest_highlight_reset
	stub _zsh_autosuggest_clear
	stub _zsh_autosuggest_highlight_apply

	# Call the function pointed to by the widget since we can't call
	# the widget itself when zle is not active
	${widgets[autosuggest-clear]#*:} 'original-widget'

	assertTrue \
		'autosuggest-clear widget does not exist' \
		'zle -l autosuggest-clear'

	assertTrue \
		'highlight_reset was not called' \
		'stub_called _zsh_autosuggest_highlight_reset'

	assertTrue \
		'widget function was not called' \
		'stub_called _zsh_autosuggest_clear'

	assertTrue \
		'highlight_apply was not called' \
		'stub_called _zsh_autosuggest_highlight_apply'
}

run_tests "$0"
