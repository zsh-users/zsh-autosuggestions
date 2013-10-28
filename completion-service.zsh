#!/bin/zsh
# Based on:
# https://github.com/Valodim/zsh-capture-completion/blob/master/capture.zsh

zmodload zsh/zpty
setopt noglob

zpty z ZLE_DISABLE_AUTOSUGGEST=1 zsh -i

# Source the init script
zpty -w z "source '${0:a:h}/completion-service-init.zsh'"

read-to-null() {
	while zpty -r z chunk; do
		[[ $chunk == *$'\0'* ]] && break
		print -n $chunk
	done
}

# wait for ok from shell
read-to-null &> /dev/null

while read prefix &> /dev/null; do
	zpty -w -n z $prefix$'\t'
	zpty -r z chunk &> /dev/null # read empty line before completions
	read-to-null
	zpty -w z $'\n'
done
