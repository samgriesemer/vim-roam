# Introduction
Vim-roam is a Vim plugin for managing a note graph connected via wikilinks. The name
"vim-roam" takes from the popular note taking tool [Roam
research](https://roamresearch.com), which is widely considered to have popularized the
notion of highly interconnected notes and an integrated _backlink_ explorer. The goal of
this plugin is to implement useful utilities for networked note management in Vim, namely
maintenance of a link graph and writing context-rich backlink content to a buffer.

Note: this plugin does not intent to replace an outer wiki management plugin such as
`wiki.vim` or `vimwiki`. It instead aims to complete these plugins by adding a richer
backlink ecosystem and additional search rules, among other things.

Note$^2$: there many additional ideas for practices and philosophies on my 


## Table of contents
- [Installation](#installation)
- [Usage](#usage)
- [Related projects](#related-projects)


# Installation
As mentioned, this plugin is best accompanied with `wiki.vim` as the surrounding wiki
environment, having many useful navigational mappings, page creation/renaming/updating,
etc. It's also extremely lightweight, and does not interfere with filetype plugins.
However, it is not explicitly required to use `vim-roam`; so long as you have a directory
of files that link among themselves using wiki link syntax `[[<link>]]`, Vim-roam should work
for you.

## Vim
Using a Vim plugin manager like Plug, installation is simple:

```vim
Plug '3000/asyncrun.vim'
Plug 'samgriesemer/vim-roam'
```

These plugins can be also be installed using Vim's native plugin support:

## Python
You will need a version of Vim built with Python3 support. You can check this by running
`vim --version` in your terminal. If you see `+python3` in the shown features, you're all
set.

There are then a few Python packages required, which are specified in the
`requirements.txt` file. Install these globally with

```bash
pip3 install --upgrade -r requirements.txt
```

If you instead have a Python virtualenv for vim plugin Python packages, you can of course
install there instead.

## Pandoc
You may also need a version of Pandoc installed and available on your PATH. check if ships
with pypandoc


# Usage

## Dependencies
This plugin builds on the fantastic [wiki.vim](https://github.com/lervag/wiki.vim) plugin,
which implements a lightweight core for managing a personal wiki in Vim. A separate
`wiki.vim` [development fork](https://github.com/samgriesemer/wiki.vim) is maintained for
managing low-level changes needed for `vim-roam` functionality. This is purposefully
separated from the main `vim-roam` repo to clearly distinguish the extended features and
configuration that fall outside the scope of the original `wiki.vim` project.

## What does it do
`vim-roam` makes it easy to maintain a personal wiki on a set of local Markdown files.
Most of this is enabled by the core `wiki.vim` functionality (see their
[documentation](https://github.com/lervag/wiki.vim) for more), but `vim-roam` extends this
by improving the underlying note graph system and backlink exploration.

More broadly, the `vim-roam` initiative encompasses a set of
[ideals](https://samgriesemer.com/Vim-roam) and compatible external tools that create a
better overall wiki experience. These include the direct `vim-roam` extensions
[vim-roam-task](https://github.com/samgriesemer/vim-roam-task) (for task management) and
[vim-roam-md](https://github.com/samgriesemer/vim-roam-md) (for syntax highlighting), as
well as more general tools like [fzf.vim](https://github.com/junegunn/fzf.vim),
[ultisnips](https://github.com/SirVer/ultisnips),
[tabular](https://github.com/godlygeek/tabular), and
[bullets.vim](https://github.com/dkarter/bullets.vim)

## Comparison with Vimwiki
Compared to `vim-roam` and `wiki.vim`, [vimwiki](https://github.com/vimwiki/vimwiki) is a
slightly bulkier plugin with a larger feature scope that may introduce conflicts or hinder
customization. `vim-roam` and `wiki.vim` are likely more suitable for those interested in
greater low-level control over their Vim environment and wish to use external Markdown
filetype plugins without conflicts. That said, you should absolutely give `vimwiki` a look
if you haven't already; it does a lot of things well, has an active community, and could
satisfy all of your needs. 

