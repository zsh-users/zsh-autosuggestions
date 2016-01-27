# zsh-autosuggestions

_[Fish](http://fishshell.com/)-like fast/unobtrusive autosuggestions for zsh._

It suggests commands as you type, based on command history.


## Installation

### Using [Antigen](https://github.com/zsh-users/antigen)

1. Load `tarruda/zsh-autosuggestions` using antigen in your `~/.zshrc` file, for example:

    ```
    # Load the script
    antigen bundle tarruda/zsh-autosuggestions autosuggestions.zsh
    ```

2. Enable autosuggestions by adding the following snippet to your `~/.zshrc` file:

    ```
    # Enable autosuggestions
    zle-line-init() {
        autosuggest_start
    }

    zle -N zle-line-init
    ```

3. Start a new terminal session or `source ~/.zshrc`


### Install Manually

1. Clone this repository to `~/.zsh/zsh-autosuggestions` (or anywhere else):

    ```sh
    git clone git://github.com/tarruda/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    ```

2. Load and enable autosuggestions by adding the following snippet to your `~/.zshrc` file:

    ```sh
    # Load the script
    source ~/.zsh/zsh-autosuggestions/autosuggestions.zsh

    # Enable autosuggestions
    zle-line-init() {
        autosuggest_start
    }

    zle -N zle-line-init
    ```

3. Start a new terminal session or `source ~/.zshrc`


## How to use

As you type commands, you will see a completion offered after the cursor in a muted gray color. This color can be changed. See [configuration](#configuration).

To accept the autosuggestion (replacing the command line contents), position your cursor at the end of the buffer and use the right arrow key.

If the autosuggestion is not what you want, go ahead and edit it. It won't execute unless you accept it.


## Configuration

You may override default global config variables after plugin load, i.e. put this somewhere in your .zshrc after the code that loads plugins.

- `ZSH_AUTOSUGGEST_HIGHLIGHT_COLOR`: Color to use when highlighting the autosuggestion
- `ZSH_AUTOSUGGEST_CLEAR_WIDGETS`: List of widgets that clear the autosuggestion
- `ZSH_AUTOSUGGEST_MODIFY_WIDGETS`: List of widgets that modify the autosuggestion
- `ZSH_AUTOSUGGEST_ACCEPT_WIDGETS`: List of widgets that accept the autosuggestion

See defaults and more info [here](tarruda/zsh-autosuggestions/blob/master/lib/config.zsh).

## Uninstallation

Just remove the config lines from `~/.zshrc` that you added during [installation](#installation). If you installed manually, then also delete `~/.zsh/zsh-autosuggestions` or wherever you installed it.


## License

This project is licensed under [MIT license](http://opensource.org/licenses/MIT).
For the full text of the license, see the [LICENSE](LICENSE) file.
