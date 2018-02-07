# zsh-augosuggestion: predefined strategy
# 1. search in history, returns result if it exists
# 2. search in predefined files
#
# configuration:
# 
# ZSH_AUTOSUGGEST_PREDEFINE_NAME  - auto generated predefine file name
# ZSH_AUTOSUGGEST_PREDEFINE_PATH  - user defined files separated by semicolon
#
# "$HOME/.zsh_autosuggest" will be generated at the first time
#
# zsh-autosuggestions/predefined.txt is generated from tldr pages and
# will ship with predefined.zsh .
#

_zsh_autosuggest_script_path="${0:A:h}"

_zsh_autosuggest_predefined_generate() {
    local pname="$HOME/.zsh_autosuggest"
    pname="${ZSH_AUTOSUGGEST_PREDEFINE_NAME:-$pname}"
    local suggests=()
    local pwd=$(pwd)
	
	# skip when ~/.zsh_autosuggest exists
	[ -f "$pname" ] && return

	echo "autosuggestions is generating: $pname"

	# copy builtin predefine database
	local txt="${_zsh_autosuggest_script_path}/predefined.txt"

	[ -f "$txt" ] && cat "$txt" > "$pname"

	# enumerate commands in $PATH and add them to ~/.zsh_autosuggest
    for p ("${(@s/:/)PATH}"); do
        cd "$p"
        local files=("${(@f)$(ls -la | awk -F ' ' '{print $9}')}")
        for fn in ${files}; do
            if [ -x "$fn" ] && [[ "${fn:l}" != *.dll ]]; then
                if [ -f "$fn" ] && [[ "${fn:l}" != *.nls ]]; then
                    # trim cygwin .exe/.cmd/.bat postfix
                    if [[ "$fn" == *.exe ]]; then
                        fn=${fn/%.exe/}
                    elif [[ "$fn" == *.cmd ]]; then
                        fn=${fn/%.cmd/}
                    elif [[ "$fn" == *.bat ]]; then
                        fn=${fn/%.bat/}
                    fi
                    if [[ ${#fn} -gt 1 ]]; then
                        suggests+=$fn
                    fi
                fi
            fi
        done
    done
    cd "${pwd}"

	# TODO: generate command parameters from completion database
	
	print -l $suggests >> "$pname"
}


_zsh_autosuggest_strategy_predefined() {
    emulate -L zsh
    setopt EXTENDED_GLOB
    local prefix="${1//(#m)[\\*?[\]<>()|^~#]/\\$MATCH}"
    local result="${history[(r)${prefix}*]}"

    if [[ $result == "" ]]; then
        if (( ! ${+_ZSH_AUTOSUGGEST_PREDEFINE} )); then
            typeset -g _ZSH_AUTOSUGGEST_PREDEFINE=()
            local pname="$HOME/.zsh_autosuggest"
            pname="${ZSH_AUTOSUGGEST_PREDEFINE_NAME:-$pname}"
            local names="${ZSH_AUTOSUGGEST_PREDEFINE_PATH};$pname"
            local array=()
            for i ("${(s:;:)names}"); do
                if [[ -n "$i" ]] && [[ -f "$i" ]]; then
                    local temp=(${(f)"$(<$i)"})
                    array+=($temp)
                fi
            done
            _ZSH_AUTOSUGGEST_PREDEFINE+=($array)
        fi
        result="${_ZSH_AUTOSUGGEST_PREDEFINE[(r)${prefix}*]}"
    fi

    typeset -g suggestion="$result"
}


_zsh_autosuggest_predefined_generate

#  vim: set ts=4 sw=4 tw=0 noet :


