
#--------------------------------------------------------------------#
# Default Suggestion Strategy                                        #
#--------------------------------------------------------------------#
# Suggests the most recent history item that matches the given
# prefix.
#

_zsh_autosuggest_strategy_default() {
	fc -lnrm "$1*" 1 2>/dev/null | head -n 1
}
