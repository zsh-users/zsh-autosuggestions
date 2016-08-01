# zsh-autosuggestions

_[Fish](http://fishshell.com/)-like fast/unobtrusive autosuggestions for zsh._

It suggests commands as you type, based on command history.

<a href="https://asciinema.org/a/37390" target="_blank"><img src="https://asciinema.org/a/37390.png" width="400" /></a>


## Installation

### Manual

1. Clone this repository somewhere on your machine. This guide will assume `~/.zsh/zsh-autosuggestions`.

    ```sh
    git clone git://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    ```

2. Add the following to your `.zshrc`:

    ```sh
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    ```

3. Start a new terminal session.


### Oh My Zsh

1. Clone this repository into `$ZSH_CUSTOM/plugins` (by default `~/.oh-my-zsh/custom/plugins`)

    ```sh
    git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    ```

2. Add the plugin to the list of plugins for Oh My Zsh to load:

    ```sh
    plugins=(zsh-autosuggestions)
    ```

3. Start a new terminal session.


## Usage

As you type commands, you will see a completion offered after the cursor in a muted gray color. This color can be changed by setting the `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE` variable. See [configuration](#configuration).

If you press the <kbd>→</kbd> key (`forward-char` widget) or <kbd>End</kbd> (`end-of-line` widget) with the cursor at the end of the buffer, it will accept the suggestion, replacing the contents of the command line buffer with the suggestion.

If you invoke the `forward-word` widget, it will partially accept the suggestion up to the point that the cursor moves to.


## Configuration

You may want to override the default global config variables after sourcing the plugin. Default values of these variables can be found [here](src/config.zsh).

**Note:** If you are using Oh My Zsh, you can put this configuration in a file in the `$ZSH_CUSTOM` directory. See their comments on [overriding internals](https://github.com/robbyrussell/oh-my-zsh/wiki/Customization#overriding-internals).


### Suggestion Highlight Style

Set `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE` to configure the style that the suggestion is shown with. The default is `fg=8`.


### Suggestion Strategy

Set `ZSH_AUTOSUGGEST_STRATEGY` to choose the strategy for generating suggestions. There are currently two to choose from:

- `default`: Chooses the most recent match.
- `match_prev_cmd`: Chooses the most recent match whose preceding history item matches the most recently executed command ([more info](src/strategies/match_prev_cmd.zsh)). Note that this strategy won't work as expected with ZSH options that don't preserve the history order such as `HIST_IGNORE_ALL_DUPS` or `HIST_EXPIRE_DUPS_FIRST`.


### Widget Mapping

This plugin works by triggering custom behavior when certain [zle widgets](http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets) are invoked. You can add and remove widgets from these arrays to change the behavior of this plugin:

- `ZSH_AUTOSUGGEST_CLEAR_WIDGETS`: Widgets in this array will clear the suggestion when invoked.
- `ZSH_AUTOSUGGEST_ACCEPT_WIDGETS`: Widgets in this array will accept the suggestion when invoked.
- `ZSH_AUTOSUGGEST_EXECUTE_WIDGETS`: Widgets in this array will execute the suggestion when invoked.
- `ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS`: Widgets in this array will partially accept the suggestion when invoked.
- `ZSH_AUTOSUGGEST_IGNORE_WIDGETS`: Widgets in this array will not trigger any custom behavior.

Widgets that modify the buffer and are not found in any of these arrays will fetch a new suggestion after they are invoked.

**Note:** A widget shouldn't belong to more than one of the above arrays.


### Disabling suggestion for large buffers

Set `ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE` to an integer value to disable autosuggestion for large buffers. The default is unset, which means that autosuggestion will be tried for any buffer size. Recommended value is 20.
This can be useful when pasting large amount of text in the terminal, to avoid triggering autosuggestion for too long strings.


### Key Bindings

This plugin provides three widgets that you can use with `bindkey`:

1. `autosuggest-accept`: Accepts the current suggestion.
2. `autosuggest-execute`: Accepts and executes the current suggestion.
3. `autosuggest-clear`: Clears the current suggestion.

For example, this would bind <kbd>ctrl</kbd> + <kbd>space</kbd> to accept the current suggestion.

```sh
bindkey '^ ' autosuggest-accept
```


## Troubleshooting

If you have a problem, please search through [the list of issues on GitHub](https://github.com/zsh-users/zsh-autosuggestions/issues) to see if someone else has already reported it.


### Reporting an Issue

Before reporting an issue, please try temporarily disabling sections of your configuration and other plugins that may be conflicting with this plugin to isolate the problem.

When reporting an issue, please include:

- The smallest, simplest `.zshrc` configuration that will reproduce the problem. See [this comment](https://github.com/zsh-users/zsh-autosuggestions/issues/102#issuecomment-180944764) for a good example of what this means.
- The version of zsh you're using (`zsh --version`)
- Which operating system you're running


## Uninstallation

1. Remove the code referencing this plugin from `~/.zshrc`.

2. Remove the git repository from your hard drive

    ```sh
    rm -rf ~/.zsh/zsh-autosuggestions # Or wherever you installed
    ```


## Development

### Build Process

Edit the source files in `src/`. Run `make` to build `zsh-autosuggestions.zsh` from those source files.


### Pull Requests

Pull requests are welcome! If you send a pull request, please:

- Request to merge into the `develop` branch (*NOT* `master`)
- Match the existing coding conventions.
- Include helpful comments to keep the barrier-to-entry low for people new to the project.
- Write tests that cover your code as much as possible.


### Testing

Testing is performed with [`shunit2`](https://github.com/kward/shunit2) (v2.1.6). Documentation can be found [here](http://shunit2.googlecode.com/svn/trunk/source/2.1/doc/shunit2.html).

The test script lives at `script/test_runner.zsh`. To run the tests, run `make test`.


## License

This project is licensed under [MIT license](http://opensource.org/licenses/MIT).
For the full text of the license, see the [LICENSE](LICENSE) file.
