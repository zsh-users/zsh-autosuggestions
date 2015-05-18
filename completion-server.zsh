#!/usr/bin/env zsh
# Based on:
# https://github.com/Valodim/zsh-capture-completion/blob/master/capture.zsh

# read everything until a line containing the byte 0 is found
read-to-null() {
	while zpty -r z chunk; do
		[[ $chunk == *$'\0'* ]] && break
		[[ $chunk != $'\1'* ]] && continue # ignore what doesnt start with '1'
		print -n - ${chunk:1}
	done
}

accept-connection() {
	zsocket -a $server
	fds[$REPLY]=1
	print "connection accepted, fd: $REPLY" >&2
}

handle-request() {
	local connection=$1 current line
	integer read_something=0
	print "request received from fd $connection"
	while read -u $connection prefix &> /dev/null; do
		read_something=1
		# send the prefix to be completed followed by a TAB to force
		# completion
		zpty -w -n z $prefix$'\t'
		zpty -r z chunk &> /dev/null # read empty line before completions
		current=''
		# read completions one by one, storing the longest match
		read-to-null | while IFS= read -r line; do
			(( $#line > $#current )) && current=$line
		done
		# send the longest completion back to the client, strip the last
		# non-printable character
		if (( $#current )); then
			print -u $connection - $prefix$'\2'${current:0:-1}
		else
			print -u $connection ''
		fi
		# clear input buffer
		zpty -w z $'\n'
		break # handle more requests/return to zselect
	done
	if ! (( read_something )); then
		print "connection with fd $connection closed" >&2
		unset fds[$connection]
		exec {connection}>&- # free the file descriptor
	fi
}


if [[ -n $ZLE_AUTOSUGGEST_SERVER_LOG ]]; then
	exec >> "$HOME/.autosuggest-server.log"
else
	exec > /dev/null
fi

if [[ -n $ZLE_AUTOSUGGEST_SERVER_LOG_ERRORS ]]; then
	exec 2>> "$HOME/.autosuggest-server-errors.log"
else
	exec 2> /dev/null
fi

exec < /dev/null

zmodload zsh/zpty
zmodload zsh/zselect
zmodload zsh/net/socket
setopt noglob
print "autosuggestion server started, pid: $$" >&2

# Start an interactive zsh connected to a zpty
zpty z ZLE_DISABLE_AUTOSUGGEST=1 zsh -i
print 'interactive shell started'
# Source the init script
zpty -w z "source '${0:a:h}/completion-server-init.zsh'"

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
	exit
}

trap cleanup TERM INT HUP EXIT

mkdir -m 700 $server_dir

while ! zsocket -l $socket_path; do
	if [[ ! -r $pid_file ]] || ! kill -0 $(<$pid_file); then
		rm -f $socket_path
	else
		exit 1
	fi
	print "will retry listening on '$socket_path'"
done

server=$REPLY

print "server listening on '$socket_path'"

print $$ > $pid_file

typeset -A fds ready
fds[$server]=1

while zselect -A ready ${(k)fds}; do
	queue=(${(k)ready})
	for fd in $queue; do
		if (( fd == server )); then
			accept-connection
		else
			handle-request $fd
		fi
	done
done
