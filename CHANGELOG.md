# Changelog

## v0.3.3
- Switch from $history array to fc builtin for better performance with large HISTFILEs (#164)
- Fix tilde handling when extended_glob is set (#168)
- Add config option for maximum buffer length to fetch suggestions for (#178)
- Add config option for list of widgets to ignore (#184)
- Don't fetch a new suggestion unless a modification widget actually modifies the buffer (#183)

## v0.3.2
- Test runner now supports running specific tests and choosing zsh binary
- Return code from original widget is now correctly passed through (#135)
- Add `vi-add-eol` to list of accept widgets (#143)
- Escapes widget names within evals to fix problems with irregular widget names (#152)
- Plugin now clears suggestion while within a completion menu (#149)
- .plugin file no longer relies on symbolic link support, fixing issues on Windows (#156)

## v0.3.1

- Fixes issue with `vi-next-char` not accepting suggestion (#137).
- Fixes global variable warning when WARN_CREATE_GLOBAL option enabled (#133).
- Split out a separate test file for each widget.

## v0.3.0

- Adds `autosuggest-execute` widget (PR #124).
- Adds concept of suggestion "strategies" for different ways of fetching suggestions.
- Adds "match_prev_cmd" strategy (PR #131).
- Uses git submodules for testing dependencies.
- Lots of test cleanup.
- Various bug fixes for zsh 5.0.x and `sh_word_split` option.


## v0.2.17

Start of changelog.
