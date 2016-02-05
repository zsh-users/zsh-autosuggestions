
#----------------#
# Widget Helpers #
#----------------#

# Bind a single widget to an autosuggest widget, saving a reference to the original widget
_zsh_autosuggest_bind_widget() {
	local widget=$1
	local autosuggest_function=$2
	local prefix=$ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX
	local action

	case $widgets[$widget] in
		# Already bound
		user:_zsh_autosuggest_(bound|orig)_*);;

		# User-defined widget
		user:*)
			zle -N $prefix$widget ${widgets[$widget]#*:}
			;;

		# Built-in widget
		builtin)
			eval "_zsh_autosuggest_orig_$widget() { zle .$widget }"
			zle -N $prefix$widget _zsh_autosuggest_orig_$widget
			;;

		# Completion widget
		completion:*)
			eval "zle -C $prefix$widget ${${widgets[$widget]#*:}/:/ }"
			;;
	esac

	# Set up widget to call $autosuggest_function if it exists
	# Otherwise just call the original widget
	if [ -n "$autosuggest_function" ]; then;
		action=$autosuggest_function;
	else;
		action="zle $prefix$widget \$@"
	fi

	# Create new function for the widget that highlights and calls the action
	eval "_zsh_autosuggest_bound_$widget() {
		_zsh_autosuggest_highlight_reset
		$action
		_zsh_autosuggest_highlight_apply
	}"

	# Create the bound widget
	zle -N $widget _zsh_autosuggest_bound_$widget
}

# Map all configured widgets to the right autosuggest widgets
_zsh_autosuggest_bind_widgets() {
	local widget;

	# Find every widget we might want to bind and bind it appropriately
	for widget in ${${(f)"$(builtin zle -la)"}:#(.*|_*|orig-*|autosuggest-*|$ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX*|run-help|which-command|beep|set-local-history|yank)}; do
		if [ ${ZSH_AUTOSUGGEST_MODIFY_WIDGETS[(r)$widget]} ]; then
			_zsh_autosuggest_bind_widget $widget _zsh_autosuggest_modify
		elif [ ${ZSH_AUTOSUGGEST_CLEAR_WIDGETS[(r)$widget]} ]; then
			_zsh_autosuggest_bind_widget $widget _zsh_autosuggest_clear
		elif [ ${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[(r)$widget]} ]; then
			_zsh_autosuggest_bind_widget $widget _zsh_autosuggest_accept
		elif [ ${ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS[(r)$widget]} ]; then
			_zsh_autosuggest_bind_widget $widget _zsh_autosuggest_partial_accept
		else
			_zsh_autosuggest_bind_widget $widget
		fi
	done
}

# Given the name of a widget, invoke the original we saved, if it exists
_zsh_autosuggest_invoke_original_widget() {
	local original_widget_name="$ZSH_AUTOSUGGEST_ORIGINAL_WIDGET_PREFIX$1"

	if [ $widgets[$original_widget_name] ]; then
		zle $original_widget_name
	fi
}
