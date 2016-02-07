# zsh-autosuggestions

_[Fish](http://fishshell.com/)-like fast/unobtrusive autosuggestions for zsh._

It suggests commands as you type, based on command history.


## Installation

1. Clone this repository somewhere on your machine. This guide will assume `~/.zsh/zsh-autosuggestions`.

    ```sh
    git clone git://github.com/tarruda/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    ```

2. Add the following to your `.zshrc`:

    ```sh
    source ~/.zsh/zsh-autosuggestions/dist/autosuggestions.zsh
    autosuggest_start
    ```

    **Note:** If you're using other zle plugins like `zsh-syntax-highlighting` or `zsh-history-substring-search`, check out the [section on compatibility](#compatibility-with-other-zle-plugins) below.


## Usage

As you type commands, you will see a completion offered after the cursor in a muted gray color. This color can be changed by setting the `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE` variable. See [configuration](#configuration).

If you press the <kbd>→</kbd> key (`forward-char` widget) or <kbd>End</kbd> (`end-of-line` widget) with the cursor at the end of the buffer, it will accept the suggestion, replacing the contents of the command line buffer with the suggestion.

If you invoke the `forward-word` widget, it will partially accept the suggestion up to the point that the cursor moves to.


## Configuration

You may want to override the default global config variables after sourcing the plugin. Default values of these variables can be found [here](https://github.com/tarruda/zsh-autosuggestions/blob/master/src/config.zsh).


### Suggestion Highlight Style

Set `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE` to configure the style that the suggestion is shown with. The default is `fg=8`.


### Widget Mapping

This plugin works by triggering custom behavior when certain [zle widgets](http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets) are invoked. You can add and remove widgets from these arrays to change the behavior of this plugin:

- `ZSH_AUTOSUGGEST_CLEAR_WIDGETS`: Widgets in this array will clear the suggestion when invoked.
- `ZSH_AUTOSUGGEST_MODIFY_WIDGETS`: Widgets in this array will modify the buffer and fetch a new suggestion when invoked.
- `ZSH_AUTOSUGGEST_ACCEPT_WIDGETS`: Widgets in this array will accept the suggestion when invoked.
- `ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS`: Widgets in this array will partially accept the suggestion when invoked.

**Note:** These arrays must be set before calling `autosuggest_start`.

**Note:** A widget shouldn't belong to more than one of the above arrays.


### Key Bindings

This plugin provides two widgets that you can use with `bindkey`:

1. `autosuggest-accept`: Accepts the current suggestion.
2. `autosuggest-clear`: Clears the current suggestion.

For example, this would bind <kbd>ctrl</kbd> + <kbd>space</kbd> to accept the current suggestion.

```sh
bindkey '^ ' autosuggest-accept
```


## Compatibility With Other ZLE Plugins


### [`zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting)

Source `zsh-autosuggestions.zsh` *before* `zsh-syntax-highlighting`.

Call `autosuggest_start` *after* sourcing `zsh-syntax-highlighting`.

For example:

```sh
source ~/.zsh/zsh-autosuggestions/dist/autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

autosuggest_start
```


### [`zsh-history-substring-search`](https://github.com/zsh-users/zsh-history-substring-search)

When the buffer is empty and one of the `history-substring-search-up/down` widgets is invoked, it will call the `up/down-line-or-history` widget. If the `up/down-line-or-history` widgets are in `ZSH_AUTOSUGGEST_CLEAR_WIDGETS` (the list of widgets that clear the suggestion), this can create an infinite recursion, crashing the shell session.

For best results, you'll want to remove `up-line-or-history` and `down-line-or-history` from `ZSH_AUTOSUGGEST_CLEAR_WIDGETS`:

```
# Remove *-line-or-history widgets from list of widgets that clear the autosuggestion to avoid conflict with history-substring-search-* widgets
ZSH_AUTOSUGGEST_CLEAR_WIDGETS=("${(@)ZSH_AUTOSUGGEST_CLEAR_WIDGETS:#(up|down)-line-or-history}")
```

Additionally, the `history-substring-search-up` and `history-substring-search-down` widgets are not bound by default. You'll probably want to add them to `ZSH_AUTOSUGGEST_CLEAR_WIDGETS` so that the suggestion will be cleared when you start searching through history:

```sh
# Add history-substring-search-* widgets to list of widgets that clear the autosuggestion
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-substring-search-up history-substring-search-down)
```

Make sure you add/remove these widgets *before* calling `autosuggest_start`.

For example:

```sh
source ~/.zsh/zsh-autosuggestions/dist/autosuggestions.zsh
source ~/Code/zsh-history-substring-search/zsh-history-substring-search.zsh

ZSH_AUTOSUGGEST_CLEAR_WIDGETS=("${(@)ZSH_AUTOSUGGEST_CLEAR_WIDGETS:#(up|down)-line-or-history}")
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-substring-search-up history-substring-search-down)

autosuggest_start
```


## Troubleshooting

If you have a problem, please search through [the list of issues on GitHub](https://github.com/tarruda/zsh-autosuggestions/issues) to see if someone else has already reported it.


### Reporting an Issue

Before reporting an issue, please try temporarily disabling sections of your configuration and other plugins that may be conflicting with this plugin to isolate the problem.

When reporting an issue, please include:

- The smallest, simplest `.zshrc` configuration that will reproduce the problem
- The version of zsh you're using (`zsh --version`)
- Which operating system you're running


## Uninstallation

1. Remove the code referencing this plugin from `~/.zshrc`.

2. Remove the git repository from your hard drive

    ```sh
    rm -rf ~/.zsh/zsh-autosuggestions # Or wherever you installed
    ```


## License

This project is licensed under [MIT license](http://opensource.org/licenses/MIT).
For the full text of the license, see the [LICENSE](LICENSE) file.
