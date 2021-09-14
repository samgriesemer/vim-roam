# Introduction
Vim-roam is a Vim plugin for managing a note graph connected via wikilinks. The name
"vim-roam" takes from the popular note taking tool [Roam
research](https://roamresearch.com), which is widely considered to have popularized the
notion of highly interconnected notes and an integrated _backlink_ explorer. The goal of
this plugin is to implement useful utilities for networked note management in Vim, namely
maintenance of a link graph and writing context-rich backlink content dynamically to a
buffer.

**Note**: this plugin does not intend to replace an outer wiki management plugin such as
`wiki.vim`. It instead aims to complement these plugins by adding a richer backlink
ecosystem and easy extendibility via [extensions](#extensions). Although vim-roam does
not explicitly require an outer wiki plugin, it is highly recommended you use
[wiki.vim](https://github.com/lervag/wiki.vim/).  This is the only wiki plugin vim-roam is
guaranteed to work with; it has _not_ been tested with
[vimwiki](https://github.com/vimwiki/vimwiki).

**Note<sup>2</sup>**: while this plugin is part of my own note taking setup in Vim (and
runs smoothly on my system), it is still in early development and may not work perfectly
for you. You may or may not experience unexpected behavior depending on your filetypes or
note syntax. The plugin also does not have the level of configuration I would like at this
time, meaning it may not be easy to incorporate the plugin using the available options.
While large bugs will be fixed as they're uncovered and the configuration will mature in
the future, do not expect things to work perfectly out of the box in its current state. If
you have any feedback/suggestions/bugs/etc, please feel free to open an issue or initiate
a pull request. Contributions are very much welcome!

## Table of contents
- [Installation](#installation)
- [Demo](#demo)
- [Read before using](#read-before-using)
- [Usage](#usage)
- [Extensions](#extensions)


# Installation
As mentioned, it is highly recommended you use `wiki.vim` as the surrounding wiki
environment. If you've not used any wiki plugins for Vim, or are coming from `vimwiki`,
`wiki.vim` is a lightweight and configurable alternative. Like `vimwiki`, it offers many
useful navigational mappings, page creation/renaming, flexible wikilink syntax, etc. It's
also not a filetype plugin and doesn't interfere with other Markdown-specific plugins.

This said, `wiki.vim` is not a hard requirement for using `vim-roam`; so long as you have
a directory of files that link among themselves using a consistent wikilink syntax
(described further [below](#read-before-using)), vim-roam should work for you.

## Vim
Using a Vim plugin manager like [vim-plug](https://github.com/junegunn/vim-plug), add the
following to your `.vimrc`:

```vim
Plug 'skywind3000/asyncrun.vim'
Plug 'samgriesemer/vim-roam'
```

You can also use any other Vim plugin manager like `vundle`, `pathogen`, etc.

## Python
You will need Python3.6 or above installed on your system and available on your PATH. If
your local Vim install doesn't have `+python3` support you should still be able to use
vim-roam, as all calls to Python are made using the internal terminal.

There are a few Python packages required as specified in the `requirements.txt` file.
Install these globally with the following in your terminal:

```bash
pip3 install --upgrade -r </path/to/vim-roam>/requirements.txt
```

where `</path/to/vim-roam>` is your plugin install directory, e.g.
`~/.vim/plugged/vim-roam` (default for `vim-plug`).

If you instead have a Python virtualenv for vim plugin Python packages, you can of course
install there instead.

## Pandoc
You will also need the latest version of Pandoc (v2.14.1, link) installed and available on
your PATH. Note that if you have any trouble getting Pandoc working on your system, you
should be able to easily install it via the `pypandoc` package (a dependency installed in
the last step). Check the [PyPI page](https://pypi.org/project/pypandoc/) for more
details.

# Demo
The following gif shows basic usage of the backlink buffer:

![Basic usage](screens/vim-roam-faster.gif)


# Read before using
As of right now, `vim-roam` only works with the Markdown filetype. This is because
Pandoc's `commonmark` parser is used to get block-level context surrounding wikilinks.
This said, the Markdown requirement may be removed in the near future, as the parser only
interfaces with basic lists, headers, and paragraph objects which are common across many
wiki syntax variants.

## If using `wiki.vim`
If you are using `wiki.vim`

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
[[<file name>|<display name>]]
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


# Why you shouldn't use Vim-roam
While Vim-roam can help improve your experience navigating backlinks in your wiki, there
are a number of reasons why Vim-roam may be not be for you:

- Vim-roam is still in an early development stage. I've mostly put this together in my
  free time as I've picked up Vimscript, and this plugin may not meet the level of quality
  you've come to expect from great plugin developers.
- Vim-roam might make too restrictive to work well with your wiki setup. As mentioned
  above, 
- You don't want to use `wiki.vim`. Although not required, using `wiki.vim` makes things
  significantly easier when setting up vim-roam. `wiki.vim` _is_ required for many of the
  extensions. If you have another wiki plugin, working around the possible conflicts when
  using it with vim-roam may not be worth your time.
- Sufficient backlink functionality is already available in other plugins. `Vimwiki` and
  `wiki.vim` offer some backlink handling on their own. This is probably sufficient for
  most users, and you should look into what these plugins offer before deciding to use
  vim-roam.
- Vim-roam can be slow, or at least the initial indexing processing, depending on your
  system or wiki size. Vim-roam uses a filter over Pandoc's `commonmark` parser to extract
  positional information inside the wiki documents, which can take time for large files or
  large wikis. Luckily, it's trivial to amortize the conversion costs after initially
  indexing notes, so bulk processing only takes place once. Still, this can take some
  time; on my system it takes roughly 3 minutes to build the index for ~2500 pages.

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
Even if you don't use vim-roam's backlink functionality, some of the available "extension"
plugins listed below might be useful. These plugins were created with vim-roam in mind,
but are mostly independent of the plugin beyond overlapping configuration (i.e. your
vim-roam settings are re-used in extension plugins).

- [vim-roam-md](): syntax highlighting for Markdown wiki files. This is a slightly
  modified fork of [vim-markdown], adding concealment for wikilinks and highlighting of
  inline TeX blocks.
- [vim-roam-search](): a set of useful FZF search mappings for navigating wiki content.
  Includes fuzzy searching wiki filenames, lines in wiki pages, exact searches in special
  files (namely PDFs) with `ripgrepall`, special search rules for users with hard wrapped
  text, etc. Opened files are passed through `wiki.vim`'s page opening function, allowing
  pages to be added to the navigation history. Matched pages are also passed through
  `wiki.vim`'s `WikiFileOpen` method, which can be customized in your `.vimrc` for
  handling certain files. For example, this can be used to open a PDF file directly in a
  document viewer of choice directly from a search match.
- [vim-roam-task](): Taskwarrior integration in Markdown files. This is a fork of the
  [Taskwiki]() plugin that removes the upstream repo's dependency on Vimwiki (and replaces
  it with `wiki.vim`). This fork also adds note functionality to tasks, allowing you to
  automatically create wiki files associated with tasks and sync task metadata to Markdown
  headers.

## Custom Roam-like settings
In the case you're interesting in extra settings that might improve your wiki
experience, consider taking a look at my current
[.vimrc](https://github.com/samgriesemer/templates/blob/master/vim/.vimrc). This file is
constantly changing and by no means the "right" settings. However, there may be a few
useful settings for `wiki.vim` or one of the above extension plugins that you'd like to
replicate in your own setup. For example, when creating journal pages using `wiki.vim`, I
specify an empty path to place pages in the same flat directory as all other wiki files.
There are also a number of wikilink resolver and opener methods for `wiki.vim` that might
give you a good place to start for your own wikilink syntax.
