#!/usr/bin/env zsh

source "${0:a:h}/test_helper.zsh"

oneTimeSetUp() {
	source_autosuggestions
}

testWidgetFunctionClear() {
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

testWidgetFunctionModify() {
	BUFFER=''
	POSTDISPLAY=''

	stub_and_eval \
		_zsh_autosuggest_invoke_original_widget \
		'BUFFER+="e"'

	stub_and_echo \
		_zsh_autosuggest_suggestion \
		'echo hello'

	_zsh_autosuggest_modify 'original-widget'

	assertTrue \
		'original widget not invoked' \
		'stub_called _zsh_autosuggest_invoke_original_widget'

	assertEquals \
		'BUFFER was not modified' \
		'e' \
		"$BUFFER"

	assertEquals \
		'POSTDISPLAY does not contain suggestion' \
		'cho hello' \
		"$POSTDISPLAY"

	restore _zsh_autosuggest_invoke_original_widget
	restore _zsh_autosuggest_suggestion
}

testWidgetFunctionAcceptCursorAtEnd() {
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

testWidgetFunctionAcceptCursorNotAtEnd() {
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

testWidgetFunctionPartialAcceptCursorMovesOutOfBuffer() {
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

testWidgetFunctionPartialAcceptCursorStaysInBuffer() {
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

testWidgetAccept() {
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
}

testWidgetClear() {
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
