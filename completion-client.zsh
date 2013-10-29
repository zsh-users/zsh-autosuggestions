#!/usr/bin/env zsh
zmodload zsh/net/socket

AUTOSUGGEST_SERVER_SCRIPT="${0:a:h}/completion-server.zsh"

autosuggest-ensure-server() {
	setopt local_options no_hup
	local server_dir="/tmp/zsh-autosuggest-$USER"
	local pid_file="$server_dir/pid"
	local socket_path="$server_dir/socket"

	[[ -S $socket_path && -r $pid_file ]] && \
	 	kill -0 $(<$pid_file) &> /dev/null || \
	 	zsh $AUTOSUGGEST_SERVER_SCRIPT $server_dir $pid_file $socket_path &!

	integer remaining_tries=10
	# wait until the process is listening
	while ! [[ -d $server_dir && -r $pid_file ]] ||\
	 	! kill -0 $(<$pid_file) &> /dev/null && (( --remaining_tries )); do
		sleep 0.3
	done
	ZLE_AUTOSUGGEST_SOCKET=$socket_path
}


autosuggest-first-completion() {
	zsocket $ZLE_AUTOSUGGEST_SOCKET &>/dev/null || return 1
	local connection=$REPLY
	local completion
	print -u $connection $1
	while read -u $connection completion; do
		print ${completion}
	done
	# close fd
	exec {connection}>&-
}
