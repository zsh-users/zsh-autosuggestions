
#--------------------------------------------------------------------#
# Default Suggestion Strategy                                        #
#--------------------------------------------------------------------#
# Suggests the most recent history item that matches the given
# prefix.
#

_zsh_autosuggest_strategy_default() {
	setopt localoptions EXTENDED_GLOB

	fc -lnrm "${1//(#m)[\\()\[\]|*?~]/\\$MATCH}*" 1 2>/dev/null | head -n 1
}
