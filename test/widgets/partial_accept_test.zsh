#!/usr/bin/env zsh

source "${0:a:h}/../test_helper.zsh"

oneTimeSetUp() {
	source_autosuggestions
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

run_tests "$0"
