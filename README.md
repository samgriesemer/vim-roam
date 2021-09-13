# Introduction
Vim-roam is a Vim plugin for managing a note graph connected via wikilinks. The name
"vim-roam" takes from the popular note taking tool [Roam
research](https://roamresearch.com), which is widely considered to have popularized the
notion of highly interconnected notes and an integrated _backlink_ explorer. The goal of
this plugin is to implement useful utilities for networked note management in Vim, namely
maintenance of a link graph and writing context-rich backlink content dynamically to a
buffer.

Note: this plugin does not intend to replace an outer wiki management plugin such as
`wiki.vim`. It instead aims to complement these plugins by adding a richer backlink
ecosystem and easy extendibility via [extensions](#extensions). Although vim-roam does
not explicitly require an outer wiki plugin, it is highly recommended you use `wiki.vim`.
This is the only wiki plugin vim-roam is guaranteed to work with; it has _not_ been tested
with [vimwiki](https://github.com/vimwiki/vimwiki).

Note$^2$: while this plugin is part of my own note taking setup in Vim (and runs smoothly
on my system), it is still in early development and may not work perfectly for you. You
may or may not experience unexpected behavior depending on your filetypes or note syntax.
The plugin also does not have the level of configuration I would like at this time. While
large bugs will be fixed as they're uncovered and the option set will mature in the
future, do not expect things to work perfectly out of the box in its current stage. If you
have any feedback/suggestions/bugs/etc, please feel free to open an issue or initiate a
pull request. Contributions are very much welcome!

Note$^3$: there many additional ideas for practices and philosophies on my 


## Table of contents
- [Installation](#installation)
- [Read before using](#read-before-using)
- [Usage](#usage)
- [Related projects](#related-projects)


# Installation
As mentioned, it is highly recommended you use `wiki.vim` as the surrounding wiki
environment, having many useful navigational mappings, page creation/renaming/updating,
etc. It's also extremely lightweight, and does not interfere with filetype plugins.
However, it is not explicitly required to use `vim-roam`; so long as you have a directory
of files that link among themselves using wiki link syntax (described further
[below](#read-before-using)),
vim-roam should work for you.

## Vim
Using a Vim plugin manager like [vim-plug](https://github.com/junegunn/vim-plug),
installation is simple:

```vim
Plug 'skywind3000/asyncrun.vim'
Plug 'samgriesemer/vim-roam'
```

You can also use any other Vim plugin manager like `vundle`, `pathogen`, etc.

## Python
You will need Python3.6 or above installed on your system and available on your PATH. If
your local Vim install doesn't have `+python3` support you should still be able to use
vim-roam, as all calls to Python are made using the internal terminal.

There are a few Python packages required, specified in the `requirements.txt` file.
Install these globally with

```bash
pip3 install --upgrade -r requirements.txt
```

If you instead have a Python virtualenv for vim plugin Python packages, you can of course
install there instead.

## Pandoc
You will also need the latest version of Pandoc (v2.14.1, link) installed and available on
your PATH. One of the required Python packages,
[pypandoc](https://pypi.org/project/pypandoc/), can install the latest version for you
quite easily; see the linked PyPI page.


# Read before using
As of right now, `vim-roam` only works with the Markdown filetype. This is because
Pandoc's `commonmark` parser is used to get block-level context surrounding wikilinks.
This said, the Markdown requirement may be removed in the near future, as the parser only
interfaces with basic lists, headers, and paragraph objects which are common across many
wiki syntax variants.

## Basic options
- You will need to specify the path to your root wiki directory via the `g:roam_wiki_root`
  option in your `.vimrc`. This tells vim-roam where to recursively scan for files when
  indexing the link graph. Note that you don't need to set this option if you've already
  set a `g:wiki_root` with wiki.vim.
- You can also override the default cache path (set to `~/.cache/vim-roam`) with the
  `g:wiki_cache_root` option.
- You can control the default mappings vim-roam will set using the
  `g:roam_mappings_use_defaults` and `g:roam_mappings_global` options:
    * `g:roam_mappings_use_defaults`: if set to 0, none of the default mappings will be set.
      You can see the three mappings that are set by default in the `plugin/roam.vim` file.
    * `g:roam_mappings_global`: this option works exactly the same as its [wiki.vim
      analog](https://github.com/lervag/wiki.vim/blob/master/doc/wiki.txt#L552). If a
      dictionary of mappings is set to this variable, they will override the global mappings,
      regardless of the value of `g:roam_mappings_use_defaults`.


## Link syntax
Before using vim-roam, it's important to determine the wikilink syntax you're employing in
your notes. Derivatives of Github-flavored Markdown wikilinks have become popular, such as
the following:

```md
[[<file name>]]
[[<display name>|<file name>]]
[[<file name>#<anchor>]]
```

The brackets `[[` and `]]` enclose the filename (without a file extension) being
referenced, with an optional display name supplied before a vertical bar or an optional
anchor link (specified with `#`) following the filename. Any combination of these options
will be recognized by vim-roam, and the core filename will be extracted. Things are simple
if your wikilinks use the real underlying filename (again, without an extension e.g.
`.md`) instead of some other transformation.

If you instead prefer a wikilink style that doesn't follow the above standard, you will
need to to assign a Vimscript function to `g:roam_file2link` in your `.vimrc` that
captures how filenames are transformed into link text in your wiki. For example, I prefer
having my wikilinks natively look like prose without the extra characters for the "display
text". That is, for the file "long_file_name.md", I would link to this file using

```md
Here's a link to a [[long file name]]
```

Since vim-roam's backlink graph will index the link name as-is, the filename must first be
transformed into the link text before querying backlink results. The `roam_file2link`
function will do this automatically when set. When the links use filenames directly,
you don't need to worry about this option.

## Working with `wiki.vim`
It's worth noting that in order to use links that don't refer explicitly to the underlying
filename (as seen in the example just above), you need an outer wiki plugin that will
allow transformations of the link text before navigating to the file. By default,
`wiki.vim` does not expose this level of flexibility. If this is functionality you're
interested in, considering using my [development fork of
wiki.vim](https://github.com/samgriesemer/wiki.vim). This fork exposes a set of
customizable link-to-filename mappings that can be used to inject transformations when
completing filenames, navigating links, etc. If you choose to use this `wiki.vim` fork,
you will not need to specify the `roam_file2link` option; it will automatically be set
based on your specified `wiki.vim` filename-to-link mapping.


# Usage
The primary command exposed by vim-roam is `:ToggleBacklinkBuffer`, and is by default
mapped to `<leader>wb`. Calling this command does the following:

- A new window is created, taking on a width according to your set `&textwidth` (if not
  set, it will simply split the current window). A terminal will pop up at the bottom of
  this new window, showing progress as your wiki directory is indexed.
- When running vim-roam for the first time, this indexing process may take some time,
  especially if you have a large number of wiki files. Once the graph is built and cached,
  the backlink explorer should take almost no time to load from that point forward. Note
  that the caching process is asynchronous (through `asyncrun`), so you can still make
  edits and navigate your wiki as this indexing process finishes.
- The name of the active buffer at the time of command execution will be used to query the
  resulting link graph, and backlink content for that file will appear in the split
  window.
- As you navigate between wiki files, the backlink buffer will automatically reload
  and show backlinks for the file you're currently editing. As changes are made to the
  wiki files, vim-roam will automatically re-index new content to ensure backlinks remain
  up to date. If your wiki files change outside of vim, the next time you open the
  backlink buffer only those files that have changed since their previous cache time will
  be updated.


# Extensions

## Recommend Roam-like settings
```vim
call roam#init#option('wiki_journal', {
      \ 'name' : '',
      \ 'frequency' : 'daily',
      \ 'date_format' : {
      \   'daily' : '%Y-%m-%d',
      \   'monthly' : '%Y-%m',
      \   'yearly' : '%Y',
      \ },
\})
```
