#!/usr/bin/env zsh

SCRIPT_DIR=$(dirname "$0")
TEST_DIR=$SCRIPT_DIR/../test
DIST_DIR=$SCRIPT_DIR/../

# Use stub.sh for stubbing/mocking
source $TEST_DIR/stub-1.0.2.sh

source $DIST_DIR/zsh-autosuggestions.zsh

#--------------------------------------------------------------------#
# Highlighting                                                       #
#--------------------------------------------------------------------#

testHighlightDefaultStyle() {
	assertEquals \
		"fg=8" \
		"$ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
}

testHighlightApplyWithSuggestion() {
	orig_style=ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=4"

	BUFFER="ec"
	POSTDISPLAY="ho hello"
	region_highlight=("0 2 fg=1")

	_zsh_autosuggest_highlight_apply

	assertEquals \
		"highlight did not use correct style" \
		"0 2 fg=1 2 10 $ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" \
		"$region_highlight"

	assertEquals \
		"higlight was not saved to be removed later" \
		"2 10 $ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" \
		"$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT"

	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=orig_style
}

testHighlightApplyWithoutSuggestion() {
	BUFFER="echo hello"
	POSTDISPLAY=""
	region_highlight=("0 4 fg=1")

	_zsh_autosuggest_highlight_apply

	assertEquals \
		"region_highlight was modified" \
		"0 4 fg=1" \
		"$region_highlight"

	assertNull \
		"last highlight region was not cleared" \
		"$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT"
}

testHighlightReset() {
	BUFFER="ec"
	POSTDISPLAY="ho hello"
	region_highlight=("0 1 fg=1" "2 10 fg=8" "1 2 fg=1")
	_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT="2 10 fg=8"

	_zsh_autosuggest_highlight_reset

	assertEquals \
		"last highlight region was not removed" \
		"0 1 fg=1 1 2 fg=1" \
		"$region_highlight"

	assertNull \
		"last highlight variable was not cleared" \
		"$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT"
}

#--------------------------------------------------------------------#
# Widgets                                                            #
#--------------------------------------------------------------------#

testWidgetFunctionClear() {
	BUFFER="ec"
	POSTDISPLAY="ho hello"

	_zsh_autosuggest_clear "original-widget"

	assertEquals \
		"BUFFER was modified" \
		"ec" \
		"$BUFFER"

	assertNull \
		"POSTDISPLAY was not cleared" \
		"$POSTDISPLAY"
}

testWidgetFunctionModify() {
	BUFFER=""
	POSTDISPLAY=""

	stub_and_eval \
		_zsh_autosuggest_invoke_original_widget \
		'BUFFER+="e"'

	stub_and_echo \
		_zsh_autosuggest_suggestion \
		"echo hello"

	_zsh_autosuggest_modify "original-widget"

	assertTrue \
		"original widget not invoked" \
		"stub_called _zsh_autosuggest_invoke_original_widget"

	assertEquals \
		"BUFFER was not modified" \
		"e" \
		"$BUFFER"

	assertEquals \
		"POSTDISPLAY does not contain suggestion" \
		"cho hello" \
		"$POSTDISPLAY"

	restore _zsh_autosuggest_invoke_original_widget
	restore _zsh_autosuggest_suggestion
}

testWidgetFunctionAcceptCursorAtEnd() {
	BUFFER="echo"
	POSTDISPLAY=" hello"
	CURSOR=4

	stub _zsh_autosuggest_invoke_original_widget

	_zsh_autosuggest_accept "original-widget"

	assertTrue \
		"original widget not invoked" \
		"stub_called _zsh_autosuggest_invoke_original_widget"

	assertEquals \
		"BUFFER was not modified" \
		"echo hello" \
		"$BUFFER"

	assertEquals \
		"POSTDISPLAY was not cleared" \
		"" \
		"$POSTDISPLAY"
}

testWidgetFunctionAcceptCursorNotAtEnd() {
	BUFFER="echo"
	POSTDISPLAY=" hello"
	CURSOR=2

	stub _zsh_autosuggest_invoke_original_widget

	_zsh_autosuggest_accept "original-widget"

	assertTrue \
		"original widget not invoked" \
		"stub_called _zsh_autosuggest_invoke_original_widget"

	assertEquals \
		"BUFFER was modified" \
		"echo" \
		"$BUFFER"

	assertEquals \
		"POSTDISPLAY was modified" \
		" hello" \
		"$POSTDISPLAY"
}

testWidgetFunctionPartialAcceptCursorMovesOutOfBuffer() {
	BUFFER="ec"
	POSTDISPLAY="ho hello"
	CURSOR=1

	stub_and_eval \
		_zsh_autosuggest_invoke_original_widget \
		'CURSOR=5; LBUFFER="echo "; RBUFFER="hello"'

	_zsh_autosuggest_partial_accept "original-widget"

	assertTrue \
		"original widget not invoked" \
		"stub_called _zsh_autosuggest_invoke_original_widget"

	assertEquals \
		"BUFFER was not modified correctly" \
		"echo " \
		"$BUFFER"

	assertEquals \
		"POSTDISPLAY was not modified correctly" \
		"hello" \
		"$POSTDISPLAY"
}

testWidgetFunctionPartialAcceptCursorStaysInBuffer() {
	BUFFER="echo hello"
	POSTDISPLAY=" world"
	CURSOR=1

	stub_and_eval \
		_zsh_autosuggest_invoke_original_widget \
		'CURSOR=5; LBUFFER="echo "; RBUFFER="hello"'

	_zsh_autosuggest_partial_accept "original-widget"

	assertTrue \
		"original widget not invoked" \
		"stub_called _zsh_autosuggest_invoke_original_widget"

	assertEquals \
		"BUFFER was modified" \
		"echo hello" \
		"$BUFFER"

	assertEquals \
		"POSTDISPLAY was modified" \
		" world" \
		"$POSTDISPLAY"
}

testWidgetAccept() {
	stub _zsh_autosuggest_highlight_reset
	stub _zsh_autosuggest_accept
	stub _zsh_autosuggest_highlight_apply

	# Call the function pointed to by the widget since we can't call
	# the widget itself when zle is not active
	${widgets[autosuggest-accept]#*:} "original-widget"

	assertTrue \
		"autosuggest-accept widget does not exist" \
		"zle -l autosuggest-accept"

	assertTrue \
		"highlight_reset was not called" \
		"stub_called _zsh_autosuggest_highlight_reset"

	assertTrue \
		"widget function was not called" \
		"stub_called _zsh_autosuggest_accept"

	assertTrue \
		"highlight_apply was not called" \
		"stub_called _zsh_autosuggest_highlight_apply"
}

testWidgetClear() {
	stub _zsh_autosuggest_highlight_reset
	stub _zsh_autosuggest_clear
	stub _zsh_autosuggest_highlight_apply

	# Call the function pointed to by the widget since we can't call
	# the widget itself when zle is not active
	${widgets[autosuggest-clear]#*:} "original-widget"

	assertTrue \
		"autosuggest-clear widget does not exist" \
		"zle -l autosuggest-clear"

	assertTrue \
		"highlight_reset was not called" \
		"stub_called _zsh_autosuggest_highlight_reset"

	assertTrue \
		"widget function was not called" \
		"stub_called _zsh_autosuggest_clear"

	assertTrue \
		"highlight_apply was not called" \
		"stub_called _zsh_autosuggest_highlight_apply"
}

testEscapeCommandPrefix() {
	assertEquals \
		"Did not escape single backslash" \
		"\\\\" \
		"$(_zsh_autosuggest_escape_command_prefix "\\")"

	assertEquals \
		"Did not escape two backslashes" \
		"\\\\\\\\" \
		"$(_zsh_autosuggest_escape_command_prefix "\\\\")"

	assertEquals \
		"Did not escape parentheses" \
		"\\(\\)" \
		"$(_zsh_autosuggest_escape_command_prefix "()")"

	assertEquals \
		"Did not escape square brackets" \
		"\\[\\]" \
		"$(_zsh_autosuggest_escape_command_prefix "[]")"

	assertEquals \
		"Did not escape pipe" \
		"\\|" \
		"$(_zsh_autosuggest_escape_command_prefix "|")"

	assertEquals \
		"Did not escape star" \
		"\\*" \
		"$(_zsh_autosuggest_escape_command_prefix "*")"

	assertEquals \
		"Did not escape question mark" \
		"\\?" \
		"$(_zsh_autosuggest_escape_command_prefix "?")"
}

# For zsh compatibility
setopt shwordsplit
SHUNIT_PARENT=$0

source $TEST_DIR/shunit2-2.1.6/src/shunit2
