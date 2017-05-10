
#--------------------------------------------------------------------#
# Feature Detection                                                  #
#--------------------------------------------------------------------#

_zsh_autosuggest_feature_detect_zpty_returns_fd() {
	typeset -g _ZSH_AUTOSUGGEST_ZPTY_RETURNS_FD
	typeset -h REPLY

	zpty zsh_autosuggest_feature_detect '{ zshexit() { kill -KILL $$; sleep 1 } }'

	if (( REPLY )); then
		_ZSH_AUTOSUGGEST_ZPTY_RETURNS_FD=1
	else
		_ZSH_AUTOSUGGEST_ZPTY_RETURNS_FD=0
	fi

	zpty -d zsh_autosuggest_feature_detect
}
