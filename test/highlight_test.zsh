#!/usr/bin/env zsh

source "${0:a:h}/test_helper.zsh"

oneTimeSetUp() {
	source_autosuggestions
}

testHighlightDefaultStyle() {
	assertEquals \
		'fg=8' \
		"$ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
}

testHighlightApplyWithSuggestion() {
	local orig_style=ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE
	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=4'

	BUFFER='ec'
	POSTDISPLAY='ho hello'
	region_highlight=('0 2 fg=1')

	_zsh_autosuggest_highlight_apply

	assertEquals \
		'highlight did not use correct style' \
		"0 2 fg=1 2 10 $ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" \
		"$region_highlight"

	assertEquals \
		'higlight was not saved to be removed later' \
		"2 10 $ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" \
		"$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT"

	ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=orig_style
}

testHighlightApplyWithoutSuggestion() {
	BUFFER='echo hello'
	POSTDISPLAY=''
	region_highlight=('0 4 fg=1')

	_zsh_autosuggest_highlight_apply

	assertEquals \
		'region_highlight was modified' \
		'0 4 fg=1' \
		"$region_highlight"

	assertNull \
		'last highlight region was not cleared' \
		"$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT"
}

testHighlightReset() {
	BUFFER='ec'
	POSTDISPLAY='ho hello'
	region_highlight=('0 1 fg=1' '2 10 fg=8' '1 2 fg=1')
	_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT='2 10 fg=8'

	_zsh_autosuggest_highlight_reset

	assertEquals \
		'last highlight region was not removed' \
		'0 1 fg=1 1 2 fg=1' \
		"$region_highlight"

	assertNull \
		'last highlight variable was not cleared' \
		"$_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT"
}

run_tests "$0"
