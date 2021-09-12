# Introduction
Vim-roam is a plugin for networked note management in Vim. The name "vim-roam" takes from
the popular note taking tool [Roam research](https://roamresearch.com), and our goal is to
implement core features present in Roam (along with other growing note tools like
[Obsidian.md](https://obsidian.md), [Notion](https://notion.so), etc) in a vanilla Vim
environment.

## Dependencies
This plugin builds on the fantastic [wiki.vim](https://github.com/lervag/wiki.vim) plugin,
which implements a lightweight core for managing a personal wiki in Vim. A separate
`wiki.vim` [development fork](https://github.com/samgriesemer/wiki.vim) is maintained for
managing low-level changes needed for `vim-roam` functionality. This is purposefully
separated from the main `vim-roam` repo to clearly distinguish the extended features and
configuration that fall outside the scope of the original `wiki.vim` project.

## Installation

### Required vim packages

- `samgriesemer/vim-roam`
- `samgriesemer/wiki.vim`

### Required python modules

- [`panja`](https://github.com/samgriesemer/panja)
- `dill` 
- `pandocfilters` 
- `misaka`

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

