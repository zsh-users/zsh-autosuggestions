#!/usr/bin/env zsh
# Based on:
# https://github.com/Valodim/zsh-capture-completion/blob/master/capture.zsh

if [[ -n $ZLE_AUTOSUGGEST_SERVER_LOG ]]; then
	exec &>> "$HOME/.autosuggest-server.log"
else
	exec &> /dev/null
fi
exec < /dev/null

zmodload zsh/zpty
zmodload zsh/net/socket
setopt noglob
print "autosuggestion server started, pid: $$"

# Start an interactive zsh connected to a zpty
zpty z ZLE_DISABLE_AUTOSUGGEST=1 zsh -i
print 'interactive shell started'
# Source the init script
zpty -w z "source '${0:a:h}/completion-server-init.zsh'"

# read everything until a line containing the byte 0 is found
read-to-null() {
	while zpty -r z chunk; do
		[[ $chunk == *$'\0'* ]] && break
		[[ $chunk != $'\1'* ]] && continue # ignore what doesnt start with '1'
		print -n - ${chunk:1}
	done
}

# wait for ok from shell
read-to-null &> /dev/null
print 'interactive shell ready'

# listen on a socket for completion requests
server_dir=$1
pid_file=$2
socket_path=$3


cleanup() {
	print 'removing socket and pid file...'
	rm -f $socket_path $pid_file
	print "autosuggestion server stopped, pid: $$"
}

trap cleanup TERM INT HUP EXIT

mkdir -m 700 $server_dir &> /dev/null

while ! zsocket -l $socket_path; do
	if [[ ! -r $pid_file ]] || ! kill -0 $(<$pid_file) &> /dev/null; then
		rm -f $socket_path
	else
		exit 1
	fi
	print "will retry listening on '$socket_path'"
done

server=$REPLY

print "server listening on '$socket_path'"

print $$ > $pid_file

while zsocket -a $server &> /dev/null; do
	connection=$REPLY
	print "connection accepted, fd: $connection"
	# connection accepted, read the request and send response
	while read -u $connection prefix &> /dev/null; do
		# send the prefix to be completed followed by a TAB to force
		# completion
		zpty -w -n z $prefix$'\t'
		zpty -r z chunk &> /dev/null # read empty line before completions
		local current=''
		# read completions one by one, storing the longest match
		read-to-null | while IFS= read -r line; do
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
		print "connection closed, fd: $connection"
		# clear input buffer
		zpty -w z $'\n'
	done
done
