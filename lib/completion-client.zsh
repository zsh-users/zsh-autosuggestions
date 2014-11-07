#!/usr/bin/env zsh
zmodload zsh/net/socket

AUTOSUGGEST_SERVER_SCRIPT="${0:a:h}/completion-server.zsh"

autosuggest-ensure-server() {
	setopt local_options no_hup
	local server_dir="/tmp/zsh-autosuggest-$USER"
	local pid_file="$server_dir/pid"
	local socket_path="$server_dir/socket"

	if [[ ! -d $server_dir || ! -r $pid_file ]] || ! kill -0 $(<$pid_file) &> /dev/null; then
		if which setsid &> /dev/null; then
			setsid zsh $AUTOSUGGEST_SERVER_SCRIPT $server_dir $pid_file $socket_path &!
		else
			zsh $AUTOSUGGEST_SERVER_SCRIPT $server_dir $pid_file $socket_path &!
		fi
	fi

	autosuggest-server-connect
}

autosuggest-server-connect() {
	unset ZLE_AUTOSUGGEST_CONNECTION

	integer remaining_tries=10
	while (( --remaining_tries )) && ! zsocket $socket_path &>/dev/null; do
		sleep 0.3
	done

	[[ -z $REPLY ]] && return 1

	ZLE_AUTOSUGGEST_CONNECTION=$REPLY
}

autosuggest-send-request() {
	[[ -z $ZLE_AUTOSUGGEST_CONNECTION ]] && return 1
	setopt local_options noglob
	print -u $ZLE_AUTOSUGGEST_CONNECTION - $1 &> /dev/null || return 1
}
