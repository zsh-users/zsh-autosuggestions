#!/usr/bin/env zsh

source "${0:a:h}/../test_helper.zsh"

oneTimeSetUp() {
	source_autosuggestions
}

setUp() {
	BUFFER=''
	POSTDISPLAY=''
	CURSOR=0
	KEYMAP='main'
}

tearDown() {
	restore _zsh_autosuggest_invoke_original_widget
}

testCursorAtEnd() {
	BUFFER='echo'
	POSTDISPLAY=' hello'
	CURSOR=4

	stub _zsh_autosuggest_invoke_original_widget

	_zsh_autosuggest_accept 'original-widget'

	assertTrue \
		'original widget not invoked' \
		'stub_called _zsh_autosuggest_invoke_original_widget'

	assertEquals \
		'BUFFER was not modified' \
		'echo hello' \
		"$BUFFER"

	assertEquals \
		'POSTDISPLAY was not cleared' \
		'' \
		"$POSTDISPLAY"
}

testCursorNotAtEnd() {
	BUFFER='echo'
	POSTDISPLAY=' hello'
	CURSOR=2

	stub _zsh_autosuggest_invoke_original_widget

	_zsh_autosuggest_accept 'original-widget'

	assertTrue \
		'original widget not invoked' \
		'stub_called _zsh_autosuggest_invoke_original_widget'

	assertEquals \
		'BUFFER was modified' \
		'echo' \
		"$BUFFER"

	assertEquals \
		'POSTDISPLAY was modified' \
		' hello' \
		"$POSTDISPLAY"
}

testViCursorAtEnd() {
	BUFFER='echo'
	POSTDISPLAY=' hello'
	CURSOR=3
	KEYMAP='vicmd'

	stub _zsh_autosuggest_invoke_original_widget

	_zsh_autosuggest_accept 'original-widget'

	assertTrue \
		'original widget not invoked' \
		'stub_called _zsh_autosuggest_invoke_original_widget'

	assertEquals \
		'BUFFER was not modified' \
		'echo hello' \
		"$BUFFER"

	assertEquals \
		'POSTDISPLAY was not cleared' \
		'' \
		"$POSTDISPLAY"
}

testViCursorNotAtEnd() {
	BUFFER='echo'
	POSTDISPLAY=' hello'
	CURSOR=2
	KEYMAP='vicmd'

	stub _zsh_autosuggest_invoke_original_widget

	_zsh_autosuggest_accept 'original-widget'

	assertTrue \
		'original widget not invoked' \
		'stub_called _zsh_autosuggest_invoke_original_widget'

	assertEquals \
		'BUFFER was modified' \
		'echo' \
		"$BUFFER"

	assertEquals \
		'POSTDISPLAY was modified' \
		' hello' \
		"$POSTDISPLAY"
}

testRetval() {
	stub_and_eval \
		_zsh_autosuggest_invoke_original_widget \
		'return 1'

	_zsh_autosuggest_widget_accept 'original-widget'

	assertEquals \
		'Did not return correct value from original widget' \
		'1' \
		"$?"
}

testWidget() {
	stub _zsh_autosuggest_highlight_reset
	stub _zsh_autosuggest_accept
	stub _zsh_autosuggest_highlight_apply

	# Call the function pointed to by the widget since we can't call
	# the widget itself when zle is not active
	${widgets[autosuggest-accept]#*:} 'original-widget'

	assertTrue \
		'autosuggest-accept widget does not exist' \
		'zle -l autosuggest-accept'

	assertTrue \
		'highlight_reset was not called' \
		'stub_called _zsh_autosuggest_highlight_reset'

	assertTrue \
		'widget function was not called' \
		'stub_called _zsh_autosuggest_accept'

	assertTrue \
		'highlight_apply was not called' \
		'stub_called _zsh_autosuggest_highlight_apply'

	restore _zsh_autosuggest_highlight_reset
	restore _zsh_autosuggest_accept
	restore _zsh_autosuggest_highlight_apply
}

run_tests "$0"
