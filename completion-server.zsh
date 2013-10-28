#!/usr/bin/env zsh
# Based on:
# https://github.com/Valodim/zsh-capture-completion/blob/master/capture.zsh

exec &> /dev/null

zmodload zsh/zpty
zmodload zsh/net/socket
setopt noglob

# Start an interactive zsh connected to a zpty
zpty z ZLE_DISABLE_AUTOSUGGEST=1 zsh -i
# Source the init script
zpty -w z "source '${0:a:h}/completion-server-init.zsh'"

read-to-null() {
	connection=$1
	integer consumed=0
	while zpty -r z chunk; do
		[[ $chunk == *$'\0'* ]] && break
		(( consumed++ )) && continue
		if [[ -n $connection ]]; then
			print -n -u $connection $chunk
		else
			print -n $chunk &> /dev/null
		fi
	done
}

# wait for ok from shell
read-to-null

# listen on an unix domain socket
server_dir=$1
pid_file=$2
socket_path=$3


cleanup() {
	rm -f $socket_path
	rm -f $pid_file
}

trap cleanup TERM INT HUP EXIT

mkdir $server_dir &> /dev/null

while ! zsocket -l $socket_path; do
	if [[ ! -r $pid_file ]] || ! kill -0 $(<$pid_file) &> /dev/null; then
		rm -f $socket_path
	else
		exit 1
	fi
done

print $$ > $pid_file

server=$REPLY

while zsocket -a $server &> /dev/null; do
	connection=$REPLY
	# connection accepted, read the request and send response
	while read -u $connection prefix &> /dev/null; do
		zpty -w -n z $prefix$'\t'
		zpty -r z chunk &> /dev/null # read empty line before completions
		read-to-null $connection
		exec {connection}>&-
		zpty -w z $'\n'
	done
done
