
#--------------------------------------------------------------------#
# Widget Helpers                                                     #
#--------------------------------------------------------------------#

# Bind a single widget to an autosuggest widget, saving a reference to the original widget
_zsh_autosuggest_bind_widget() {
	local widget=$1
	local autosuggest_action=$2
	local prefix=$ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX

	# Save a reference to the original widget
	case $widgets[$widget] in
		# Already bound
		user:_zsh_autosuggest_(bound|orig)_*);;

		# User-defined widget
		user:*)
			zle -N $prefix$widget ${widgets[$widget]#*:}
			;;

		# Built-in widget
		builtin)
			eval "_zsh_autosuggest_orig_${(q)widget}() { zle .${(q)widget} }"
			zle -N $prefix$widget _zsh_autosuggest_orig_$widget
			;;

		# Completion widget
		completion:*)
			eval "zle -C $prefix${(q)widget} ${${(s.:.)widgets[$widget]}[2,3]}"
			;;
	esac

	# Pass the original widget's name explicitly into the autosuggest
	# function. Use this passed in widget name to call the original
	# widget instead of relying on the $WIDGET variable being set
	# correctly. $WIDGET cannot be trusted because other plugins call
	# zle without the `-w` flag (e.g. `zle self-insert` instead of
	# `zle self-insert -w`).
	eval "_zsh_autosuggest_bound_${(q)widget}() {
		_zsh_autosuggest_widget_$autosuggest_action $prefix${(q)widget} \$@
	}"

	# Create the bound widget
	zle -N $widget _zsh_autosuggest_bound_$widget
}

# Map all configured widgets to the right autosuggest widgets
_zsh_autosuggest_bind_widgets() {
	local widget
	local ignore_widgets

	ignore_widgets=(
		.\*
		_\*
		zle-line-\*
		autosuggest-\*
		$ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX\*
		$ZSH_AUTOSUGGEST_IGNORE_WIDGETS
	)

	# Find every widget we might want to bind and bind it appropriately
	for widget in ${${(f)"$(builtin zle -la)"}:#${(j:|:)~ignore_widgets}}; do
		if [ ${ZSH_AUTOSUGGEST_CLEAR_WIDGETS[(r)$widget]} ]; then
			_zsh_autosuggest_bind_widget $widget clear
		elif [ ${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[(r)$widget]} ]; then
			_zsh_autosuggest_bind_widget $widget accept
		elif [ ${ZSH_AUTOSUGGEST_EXECUTE_WIDGETS[(r)$widget]} ]; then
			_zsh_autosuggest_bind_widget $widget execute
		elif [ ${ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS[(r)$widget]} ]; then
			_zsh_autosuggest_bind_widget $widget partial_accept
		else
			# Assume any unspecified widget might modify the buffer
			_zsh_autosuggest_bind_widget $widget modify
		fi
	done
}

# Given the name of an original widget and args, invoke it, if it exists
_zsh_autosuggest_invoke_original_widget() {
	# Do nothing unless called with at least one arg
	[ $# -gt 0 ] || return

	local original_widget_name="$1"

	shift

	if [ $widgets[$original_widget_name] ]; then
		zle $original_widget_name -- $@
	fi
}
