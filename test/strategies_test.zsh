#!/usr/bin/env zsh

source "${0:a:h}/test_helper.zsh"

oneTimeSetUp() {
	source_autosuggestions
}

assertBackslashSuggestion() {
	set_history <<-'EOF'
		echo "hello\nworld"
	EOF

	assertSuggestion \
		'echo "hello\' \
		'echo "hello\nworld"'
}

assertDoubleBackslashSuggestion() {
	set_history <<-'EOF'
		echo "\\"
	EOF

	assertSuggestion \
		'echo "\\' \
		'echo "\\"'
}

assertTildeSuggestion() {
	set_history <<-'EOF'
		cd ~/something
	EOF

	assertSuggestion \
		'cd' \
		'cd ~/something'

	assertSuggestion \
		'cd ~' \
		'cd ~/something'

	assertSuggestion \
		'cd ~/s' \
		'cd ~/something'
}

assertTildeSuggestionWithExtendedGlob() {
	setopt local_options extended_glob

	assertTildeSuggestion
}

assertParenthesesSuggestion() {
	set_history <<-'EOF'
		echo "$(ls foo)"
	EOF

	assertSuggestion \
		'echo "$(' \
		'echo "$(ls foo)"'
}

assertSquareBracketsSuggestion() {
	set_history <<-'EOF'
		echo "$history[123]"
	EOF

	assertSuggestion \
		'echo "$history[' \
		'echo "$history[123]"'
}

assertHashSuggestion() {
	set_history <<-'EOF'
		echo "#yolo"
	EOF

	assertSuggestion \
		'echo "#' \
		'echo "#yolo"'
}

testSpecialCharsForAllStrategies() {
	local strategies
	strategies=(
		"default"
		"match_prev_cmd"
	)

	for s in $strategies; do
		ZSH_AUTOSUGGEST_STRATEGY="$s"

		assertBackslashSuggestion
		assertDoubleBackslashSuggestion
		assertTildeSuggestion
		assertTildeSuggestionWithExtendedGlob
		assertParenthesesSuggestion
		assertSquareBracketsSuggestion
	done
}

run_tests "$0"
