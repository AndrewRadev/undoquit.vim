[![Build Status](https://secure.travis-ci.org/AndrewRadev/undoquit.vim.png?branch=master)](http://travis-ci.org/AndrewRadev/undoquit.vim)

This plugin attempts to solve the issue of quitting a window, and then realizing you actually need it moments later. It simply lets you "undo" the quit, similar to the way you would restore a just-closed tab in your browser.

## Requirements

Requires Vim at version 7.4 or above.

## Usage

Whenever you execute a `:quit` on a window, that window's position is stored in a stack. Pressing `<c-w>u` (or executing the `:Undoquit` command) is going to "undo" that quit, restoring the window to its original position.

Note that this only works on buffers that are "listed", so it won't restore the quickfix window or the NERDTree, but it's assumed that you don't really need this functionality for these kinds of buffers.

Use the `g:undoquit_mapping` variable to set the mapping for the action. Example:

``` vim
let g:undoquit_mapping = '_u'
```

Set the variable to an empty string to avoid setting a mapping at all.

## Issues

Internally, the plugin listens for the `QuitPre` event and does some window-hopping to establish the position of the current window. If you notice any odd behaviour when closing windows, like the wrong window gets closed or something, it may be a bug in this plugin. Please disable it and try again, and if the plugin is faulty, please open an issue on the [github bugtracker](https://github.com/AndrewRadev/undoquit.vim/issues)

A known problem is that the plugin doesn't work for `<c-w>c`, since that mapping doesn't seem to throw a `QuitPre` autocommand. If you use it, you could make it work by calling the undoquit "save history" function manually:

``` vim
nnoremap <c-w>c :call undoquit#SaveWindowQuitHistory()<cr><c-w>c
```

## Contributing

Pull requests are welcome, but take a look at [CONTRIBUTING.md](https://github.com/AndrewRadev/undoquit.vim/blob/master/CONTRIBUTING.md) first for some guidelines.
