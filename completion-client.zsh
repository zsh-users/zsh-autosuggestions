#!/usr/bin/env zsh
# Helper script for debugging the completion server
zmodload zsh/net/socket
setopt no_hup
AUTOSUGGEST_SERVER_SCRIPT="${0:a:h}/completion-server.zsh"

server_dir="/tmp/zsh-autosuggest-$USER"
pid_file="$server_dir/pid"
socket_path="$server_dir/socket"

[[ -S $socket_path && -r $pid_file ]] && kill -0 $(<$pid_file) &> /dev/null ||\
	zsh $AUTOSUGGEST_SERVER_SCRIPT $server_dir $pid_file $socket_path &!

# wait until the process is listening
while ! [[ -d $server_dir && -r $pid_file ]] || ! kill -0 $(<$pid_file) &> /dev/null; do
	sleep 0.3
done

zsocket $socket_path
connection=$REPLY
print -u $connection vi
while read -u $connection completion; do
	print $completion
done
exec {connection}>&-
