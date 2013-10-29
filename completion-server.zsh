#!/usr/bin/env zsh
# Based on:
# https://github.com/Valodim/zsh-capture-completion/blob/master/capture.zsh

# close stdio
exec &> /dev/null
exec < /dev/null

zmodload zsh/zpty
zmodload zsh/net/socket
setopt noglob

# Start an interactive zsh connected to a zpty
zpty z ZLE_DISABLE_AUTOSUGGEST=1 zsh -i
# Source the init script
zpty -w z "source '${0:a:h}/completion-server-init.zsh'"

# read all completions and return the longest match
read-to-null() {
	while zpty -r z chunk; do
		[[ $chunk == *$'\0'* ]] && break
		[[ $chunk != $'\1'* ]] && continue # ignore what doesnt start with '1'
		print -n - ${chunk:1}
	done
}

# wait for ok from shell
read-to-null &> /dev/null

# listen on a socket for completion requests
server_dir=$1
pid_file=$2
socket_path=$3


cleanup() {
	rm -f $socket_path $pid_file
}

trap cleanup TERM INT HUP EXIT

mkdir -m 700 $server_dir &> /dev/null

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
		# send the prefix to be completed followed by a TAB to force
		# completion
		zpty -w -n z $prefix$'\t'
		zpty -r z chunk &> /dev/null # read empty line before completions
		local current=''
		# read completions one by one, storing the longest match
		read-to-null | while read line; do
			(( $#line > $#current )) && current=$line
		done
		# send the longest completion back to the client, strip the last
		# non-printable character
		if (( $#current )); then
			print -u $connection - ${current:0:-1}
		else
			print -u $connection ''
		fi
		# close fd
		exec {connection}>&-
		# clear input buffer
		zpty -w z $'\n'
	done
done
