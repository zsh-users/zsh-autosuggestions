
#--------------------------------------------------------------------#
# Feature Detection                                                  #
#--------------------------------------------------------------------#

_zsh_autosuggest_feature_detect() {
	typeset -g _ZSH_AUTOSUGGEST_ZPTY_RETURNS_FD
	typeset -h REPLY

	zpty $ZSH_AUTOSUGGEST_ASYNC_PTY_NAME :

	if (( REPLY )); then
		_ZSH_AUTOSUGGEST_ZPTY_RETURNS_FD=1
	else
		_ZSH_AUTOSUGGEST_ZPTY_RETURNS_FD=0
	fi

	zpty -d $ZSH_AUTOSUGGEST_ASYNC_PTY_NAME
}
