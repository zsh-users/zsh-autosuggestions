# Based on:
# https://github.com/Valodim/zsh-capture-completion/blob/master/.zshrc

ZLE_DISABLE_AUTOSUGGEST=1
# no prompt!
PROMPT=

# load completion system
autoload compinit
compinit

# never run a command
bindkey '\C-m' .kill-buffer
bindkey '\C-j' .kill-buffer
bindkey '\C-i' complete-word

# send an emtpy line before completions are output
empty-line() {
	print
	# handler needs to reinsert itself after being called
	compprefuncs+=empty-line
}
compprefuncs+=empty-line

# send a line with null-byte after completions are output
null-line() {
	print $'\0'
	# handler needs to reinsert itself after being called
	comppostfuncs+=null-line
}
comppostfuncs+=null-line

zstyle ':completion:*' completer _complete
# never group stuff!
zstyle ':completion:*' list-grouped false
# don't insert tab when attempting completion on empty line
zstyle ':completion:*' insert-tab false
# no list separator, this saves some stripping later on
zstyle ':completion:*' list-separator ''
# dont use matchers
zstyle -d ':completion:*' matcher-list
# dont format
zstyle -d ':completion:*' format
# no color formatting
zstyle -d ':completion:*' list-colors

# we use zparseopts
zmodload zsh/zutil

# override compadd (this our hook)
compadd() {

	# check if any of -O, -A or -D are given
	if [[ ${@[1,(i)(-|--)]} == *-(O|A|D)\ * ]]; then
		# if that is the case, just delegate and leave
		builtin compadd "$@"
		return $?
	fi

	# be careful with namespacing here, we don't want to mess with stuff that
	# should be passed to compadd!
	typeset -a __hits __dscr __tmp

	# do we have a description parameter?
	# note we don't use zparseopts here because of combined option parameters
	# with arguments like -default- confuse it.
	if (( $@[(I)-d] )); then # kind of a hack, $+@[(r)-d] doesn't work because of line noise overload
		# next param after -d
		__tmp=${@[$[${@[(i)-d]}+1]]}
		# description can be given as an array parameter name, or inline () array
		if [[ $__tmp == \(* ]]; then
			eval "__dscr=$__tmp"
		else
			__dscr=( "${(@P)__tmp}" )
		fi
	fi

	# capture completions by injecting -A parameter into the compadd call.
	# this takes care of matching for us.
	builtin compadd -A __hits -D __dscr "$@"

	# JESUS CHRIST IT TOOK ME FOREVER TO FIGURE OUT THIS OPTION WAS SET AND WAS MESSING WITH MY SHIT HERE
	setopt localoptions norcexpandparam extendedglob

	# extract prefixes and suffixes from compadd call. we can't do zsh's cool
	# -r remove-func magic, but it's better than nothing.
	typeset -A apre hpre hsuf asuf
	zparseopts -E P:=apre p:=hpre S:=asuf s:=hsuf

	# append / to directories? we are only emulating -f in a half-assed way
	# here, but it's better than nothing.
	integer dirsuf=0
	# don't be fooled by -default- >.>
	if [[ -z $hsuf && "${${@//-default-/}% -# *}" == *-[[:alnum:]]#f* ]]; then
		dirsuf=1
	fi

	# just drop
	[[ -n $__hits ]] || return

	# this is the point where we have all matches in $__hits and all
	# descriptions in $__dscr!

	# display all matches
	local dsuf dscr
	for i in {1..$#__hits}; do

		# add a dir suffix?
		(( dirsuf )) && [[ -d $__hits[$i] ]] && dsuf=/ || dsuf=
		# description to be displayed afterwards
		# (( $#__dscr >= $i )) && dscr=" -- ${${__dscr[$i]}##$__hits[$i] #}" || dscr=

		print - $'\1'$IPREFIX$apre$hpre$__hits[$i]$dsuf$hsuf$asuf$dscr

	done

	unset __hits __dscr __tmp
}

# signal the daemon we are ready for input
print $'\0'
