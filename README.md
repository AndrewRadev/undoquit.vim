[![Build Status](https://secure.travis-ci.org/AndrewRadev/undoquit.vim.svg?branch=master)](http://travis-ci.org/AndrewRadev/undoquit.vim)

This plugin attempts to solve the issue of quitting a window, and then realizing you actually need it moments later. It simply lets you "undo" the quit, similar to the "Restore Tab" functionality of a browser.

For a visual demo, there's a screencast [on youtube](https://youtu.be/FnARbgfuEZA)

## Requirements

Requires Vim at version 7.4 or above.

## Usage

Whenever you execute a `:quit` on a window, that window's position is stored in a stack. Pressing `<c-w>u` (or executing the `:Undoquit` command) is going to "undo" that quit, restoring the window to its original position.

Note that this only works on buffers that are "listed", so it won't restore the quickfix window or the NERDTree, but it's assumed that you don't really need this functionality for these kinds of buffers.

### Working with tabs

The `<c-w>u` mapping will restore windows you've closed one by one, regardless if they're in the current tab, or in a different one. To restore a full tab's worth of windows, you can use `<c-w>U`. That mapping will:

- Restore all windows that you've previously closed in the current tab, if there are any
- Restore all windows in a previously-closed tab

However, it's important to note that the plugin **only** keeps track of windows closed with `:quit` or `ZZ`. It uses the `QuitPre` event to store a window's information before it's closed, and there is no similar event for other methods of closing windows.

This means that the `:tabclose` command will **not** save the closed windows in history. In case this is a command that's part of your workflow, the plugin provides the `:UndoableTabclose` command that should be usable in the same way as the built-in `:tabclose`:

```
:UndoableTabclose[!]
:{count}UndoableTabclose[!]
:UndoableTabclose[!] {count}
```

The plugin also doesn't work for `<c-w>c`, since that mapping doesn't throw a `QuitPre` autocommand either. If you use it, you could make it work by calling the undoquit "save history" function manually:

``` vim
nnoremap <c-w>c :call undoquit#SaveWindowQuitHistory()<cr><c-w>c
```

## Settings

Use the `g:undoquit_mapping` variable to set the mapping for the window restore action. Example:

``` vim
" default: <c-w>u
let g:undoquit_mapping = '_u'
```

Use `g:undoquit_tab_mapping` for the keybinding that restores a full tab of windows:

``` vim
" default: <c-w>U
let g:undoquit_tab_mapping = '_U'
```

Set any of these variables to an empty string to avoid defining a mapping at all. You could still use the plugin via its commands, `:Undoquit` and `:UndoquitTab`.

## Contributing

Pull requests are welcome, but take a look at [CONTRIBUTING.md](https://github.com/AndrewRadev/undoquit.vim/blob/master/CONTRIBUTING.md) first for some guidelines.
