#!/usr/bin/env zsh

source "${0:a:h}/../test_helper.zsh"

oneTimeSetUp() {
	source_autosuggestions
}

setUp() {
	BUFFER=''
	POSTDISPLAY=''
	CURSOR=0
}

tearDown() {
	restore _zsh_autosuggest_invoke_original_widget
}

testCursorMovesOutOfBuffer() {
	BUFFER='ec'
	POSTDISPLAY='ho hello'
	CURSOR=1

	stub_and_eval \
		_zsh_autosuggest_invoke_original_widget \
		'CURSOR=5; LBUFFER="echo "; RBUFFER="hello"'

	_zsh_autosuggest_partial_accept 'original-widget'

	assertTrue \
		'original widget not invoked' \
		'stub_called _zsh_autosuggest_invoke_original_widget'

	assertEquals \
		'BUFFER was not modified correctly' \
		'echo ' \
		"$BUFFER"

	assertEquals \
		'POSTDISPLAY was not modified correctly' \
		'hello' \
		"$POSTDISPLAY"
}

testCursorStaysInBuffer() {
	BUFFER='echo hello'
	POSTDISPLAY=' world'
	CURSOR=1

	stub_and_eval \
		_zsh_autosuggest_invoke_original_widget \
		'CURSOR=5; LBUFFER="echo "; RBUFFER="hello"'

	_zsh_autosuggest_partial_accept 'original-widget'

	assertTrue \
		'original widget not invoked' \
		'stub_called _zsh_autosuggest_invoke_original_widget'

	assertEquals \
		'BUFFER was modified' \
		'echo hello' \
		"$BUFFER"

	assertEquals \
		'POSTDISPLAY was modified' \
		' world' \
		"$POSTDISPLAY"
}

testRetval() {
	stub_and_eval \
		_zsh_autosuggest_invoke_original_widget \
		'return 1'

	_zsh_autosuggest_widget_partial_accept 'original-widget'

	assertEquals \
		'Did not return correct value from original widget' \
		'1' \
		"$?"
}

run_tests "$0"
