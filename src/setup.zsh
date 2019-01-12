
#--------------------------------------------------------------------#
# Setup                                                              #
#--------------------------------------------------------------------#

# Precmd hooks for initializing the library and starting pty's
autoload -Uz add-zsh-hook
autoload -Uz add-zle-hook-widget
autoload -Uz is-at-least

# Asynchronous suggestions are generated in a pty
zmodload zsh/zpty
