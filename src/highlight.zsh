
#--------------------------------------------------------------------#
# Highlighting                                                       #
#--------------------------------------------------------------------#

# `is-at-least` is autoloaded in src/start.zsh, but we may be called
# before start.zsh runs (e.g. another plugin triggering us). Safe to
# autoload here too — it's idempotent.
autoload -Uz is-at-least

# Array of every region_highlight entry this plugin has added. Using an
# array (instead of a single scalar) ensures every entry we own can be
# removed on reset even when:
#   * another plugin appends to region_highlight between our apply and
#     reset calls (e.g. zsh-syntax-highlighting),
#   * multiple apply calls occur without an intervening successful reset
#     (which can happen under rapid edits / widget wrapping edge cases).
typeset -ga _ZSH_AUTOSUGGEST_OWNED_HIGHLIGHTS

# Returns 0 if this zsh supports the `memo=` attribute on region_highlight
# entries (zsh 5.9+). The result is cached on first call.
_zsh_autosuggest_highlight_memo_support() {
	typeset -g _ZSH_AUTOSUGGEST_MEMO_SUPPORT
	if [[ -z "$_ZSH_AUTOSUGGEST_MEMO_SUPPORT" ]]; then
		if is-at-least 5.9; then
			_ZSH_AUTOSUGGEST_MEMO_SUPPORT=1
		else
			_ZSH_AUTOSUGGEST_MEMO_SUPPORT=0
		fi
	fi
	(( _ZSH_AUTOSUGGEST_MEMO_SUPPORT ))
}

# If there was a highlight, remove it
_zsh_autosuggest_highlight_reset() {
	typeset -g _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT

	if (( $#_ZSH_AUTOSUGGEST_OWNED_HIGHLIGHTS == 0 )); then
		unset _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT
		return
	fi

	if _zsh_autosuggest_highlight_memo_support; then
		# Single pass: drop every region_highlight entry carrying our
		# memo tag. Order-independent and robust against interleaving
		# with other plugins' entries.
		local entry
		local -a kept=()
		for entry in $region_highlight; do
			[[ "$entry" != *memo=zsh-autosuggestions* ]] && kept+=("$entry")
		done
		region_highlight=("${kept[@]}")
	else
		# Fallback for zsh < 5.9: remove by literal string comparison.
		# We intentionally do NOT use `${(@)array:#$needle}` because
		# that treats $needle as a glob pattern — `#` in hex colors
		# (e.g. `fg=#RRGGBB`) would be interpreted as pattern-matching
		# syntax and the entry would never be removed.
		# See https://github.com/zsh-users/zsh-autosuggestions/issues/789
		local owned entry
		for owned in $_ZSH_AUTOSUGGEST_OWNED_HIGHLIGHTS; do
			local -a kept=()
			local removed=0
			for entry in $region_highlight; do
				if (( ! removed )) && [[ "$entry" == "$owned" ]]; then
					removed=1
				else
					kept+=("$entry")
				fi
			done
			region_highlight=("${kept[@]}")
		done
	fi

	_ZSH_AUTOSUGGEST_OWNED_HIGHLIGHTS=()
	unset _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT
}

# If there's a suggestion, highlight it
_zsh_autosuggest_highlight_apply() {
	typeset -g _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT

	if (( $#POSTDISPLAY )); then
		local entry="$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) $ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE"
		if _zsh_autosuggest_highlight_memo_support; then
			entry+=" memo=zsh-autosuggestions"
		fi
		region_highlight+=("$entry")
		_ZSH_AUTOSUGGEST_OWNED_HIGHLIGHTS+=("$entry")

		# Retained for backwards compatibility with anything reading
		# this variable externally.
		_ZSH_AUTOSUGGEST_LAST_HIGHLIGHT="$entry"
	else
		unset _ZSH_AUTOSUGGEST_LAST_HIGHLIGHT
	fi
}
