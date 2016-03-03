# vim-lining

Small and cute status line for [Vim](http://www.vim.org) and
[NeoVim](https://neovim.io).

![Screenshot](/_misc/screenshot2.png)

(The screenshot uses the [elrond
theme](https://github.com/aperezdc/vim-elrond).)

## Features

* Automatically sets the `laststatus=2` and `showmode` options for you.
* Possible, the smallest nice-looking status line which does not require you
  to install patched fonts.
* Visual paste mode indicator (not shown in screenshot).
* If you have [Fugitive](https://github.com/tpope/vim-fugitive) installed, it
  will be used to show information on Git repositories.


## Customization

Customization is not possible at the moment. Not easily, at least.


## Theming

Theming is done via highlight groups. Note that *by default colors for Lining
are not defined*, which means that your status line will be use the plain
colors defined by your theme for `StatusLine` and `StatusLineNC`.

Lining uses the following highlight groups:

* `StatusLine` and `StatusLineNC`, as used by the default status line.
* `LiningBufName`: Name of the file in the buffer.
* `LiningWarn`: Warning flag item.
* `LiningError`: Error flag item.
* `LiningItem`: Any other item in the status line.
* `LiningVcsInfo`: Version control information.

For an example on how to theme Lining using these, you can check the [elrond
theme](https://github.com/aperezdc/vim-elrond).


## Installation

### Using [Plug](https://github.com/junegunn/vim-plug)

1. Add `Plug 'aperezdc/vim-lining'` to your `vimrc`.

2. Run `vim +PlugInstall +qall`.

### Using [NeoBundle](https://github.com/Shougo/neobundle.vim)

1. Add `NeoBundle 'aperezdc/vim-lining'` to your `vimrc`.

### Using [Vundle](https://github.com/gmarik/vundle)

1. Add `Plugin 'aperezdc/vim-lining'` to your `vimrc`.

2. Run `vim +PluginInstall +qall'`.

### Using [Pathogen](https://github.com/tpope/vim-pathogen)

Execute the following commands in a terminal:

```sh
cd ~/.vim/bundle
git clone https://github.com/aperezdc/vim-lining
```
