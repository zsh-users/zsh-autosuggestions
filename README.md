# zsh-autosuggestions

_[Fish](http://fishshell.com/)-like fast/unobtrusive autosuggestions for zsh._

It suggests commands as you type, based on command history.


## Installation

If you already use [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) plugin, then make sure to be loaded **before** zsh-autosuggestions.

Note: _.zshrc_ is a file that contains user-specific ZSH configuration.
ZSH assumes this file in your home directory (i.e. `~/.zshrc`), but the location can be changed using `ZDOTDIR` variable.

### Using zgen

[Zgen](https://github.com/tarjoilija/zgen) is a simple and fast plugin manager for ZSH.
If you don’t use zgen, then use instructions for the manual installation.

1. Load `tarruda/zsh-autosuggestions` and `zsh-users/zsh-syntax-highlighting` using zgen in your .zshrc file, for example:

    ```sh
    if ! zgen saved; then
        echo "Creating a zgen save"

        zgen load zsh-users/zsh-syntax-highlighting

        # autosuggestions should be loaded last
        zgen load tarruda/zsh-autosuggestions

        zgen save
    fi
    ```

2. Enable zsh-autosuggestions; copy the following snippet and put it after the zgen config section in your .zshrc file:

    ```sh
    # Enable autosuggestions automatically.
    zle-line-init() {
        zle autosuggest-start
    }
    zle -N zle-line-init
    ```

3. Run `zgen reset` and reopen your terminal.


### Manually

1. Clone this repository to `~/.zsh/zsh-autosuggestions` (or anywhere else):

    ```sh
    git clone git://github.com/tarruda/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    ```

2. Clone zsh-syntax-highlighting repository to `~/.zsh/zsh-syntax-highlighting` (or anywhere else):

    ```sh
    git clone git://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting
    ```

3. Load and enable autosuggestions; copy the following snippet and put it to your .zshrc file:

    ```sh
    # Load zsh-syntax-highlighting.
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    # Load zsh-autosuggestions.
    source ~/.zsh/zsh-autosuggestions/autosuggestions.zsh

    # Enable autosuggestions automatically.
    zle-line-init() {
        zle autosuggest-start
    }
    zle -N zle-line-init
    ```

4. Reopen your terminal.


## Uninstallation

Just remove the config lines from .zshrc that you’ve added during “installation.”
If you don’t use zgen, then also delete `~/.zsh/zsh-autosuggestions` and `~/.zsh/zsh-syntax-highlighting`.


## How to use

As you type commands, you will see a completion offered after the cursor, in a muted gray color (which can be changed, see [Configuration](#configuration)).
To accept the autosuggestion (replacing the command line contents), hit <kbd>End</kbd>, <kbd>Alt+F</kbd>, <kbd>Ctrl+F</kbd>, or any other key that moves the cursor to the right.
If the autosuggestion is not what you want, just ignore it: it won’t execute unless you accept it.

Any widget that moves the cursor to the right (forward-word, forward-char, end-of-line…) will accept parts of the suggested text.
For example, vi-mode users can do this:

```sh
# Accept suggestions without leaving insert mode
bindkey '^f' vi-forward-word
# or
bindkey '^f' vi-forward-blank-word
```

You can also use right arrow key to accept the suggested text as in Fish shell; see [Configuration](#configuration) section to enable it.

### Exposed widgets

This plugin defines some ZLE widgets (think about them as functions) which you can bind to some key using [bindkey](http://zshwiki.org/home/zle/bindkeys).
For example, to toggle autosuggestions using <kbd>Ctrl+T</kbd> add this to your .zshrc:

```sh
bindkey '^T' autosuggest-toggle
```

List of widgets:

 - `autosuggest-toggle` – disable/enable autosuggestions.
 - `autosuggest-execute-suggestion` – accept the suggestion and execute it.


## Configuration

You may override default global config variables after plugin load, i.e. put it to your .zshrc after the code that loads plugins.

- `AUTOSUGGESTION_HIGHLIGHT_COLOR` – suggestion highlight color, default is `'fg=8'`.
- `AUTOSUGGESTION_HIGHLIGHT_CURSOR` – highlight word after cursor, or not. Must be integer value `1` or `0`, default is `1`.
- `AUTOSUGGESTION_ACCEPT_RIGHT_ARROW` – complete entire suggestion with right arrow. Must be integer value `1` or `0`, default is `0` (right arrow completes one letter at a time).


## Known Issues

> When I hit <kbd>Tab</kbd> and autosuggestions is enabled, it deletes the previous line, and scrolls up the terminal.

This usually happens when autosuggestions is used along with something like [“completion waiting dots.”](http://michael.thegrebs.com/2012/09/04/zsh-completion-waiting-dots/)
Check which widget is bind to the Tab key; run `bindkey "^I"`.
If it prints something other than `"^I" expand-or-complete`, then this may be the problem.

If you use [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh), then make sure that the variable `COMPLETION_WAITING_DOTS` is not set (it enables [this](https://github.com/robbyrussell/oh-my-zsh/blob/e55c715508a2f652fed741f2047c66dda2c6e5b0/lib/completion.zsh#L56-L64) problematic code).

If you use module [editor](https://github.com/sorin-ionescu/prezto/tree/master/modules/editor) from [Prezto](https://github.com/sorin-ionescu/prezto), then you must comment out [these lines](https://github.com/sorin-ionescu/prezto/blob/a84ac5b0023d71c98bb28a68c550dc13f6c51945/modules/editor/init.zsh#L303-L304).


## License

This project is licensed under [MIT license](http://opensource.org/licenses/MIT).
For the full text of the license, see the [LICENSE](LICENSE) file.
