# Introduction
Vim-roam is a Vim plugin for exploring a note graph connected via wikilinks. The name
"vim-roam" takes from the popular note taking tool [Roam
research](https://roamresearch.com), which is widely considered to have popularized the
notion of highly interconnected notes and an integrated _backlink explorer_. The goal of
this plugin is to make it easy to find relevant content across local wiki files using a
similar approach, namely writing context-rich backlink content dynamically to a buffer.

**Note**: this plugin does not intend to replace an outer wiki management plugin such as
`wiki.vim`. It instead aims to complement these plugins by adding a richer backlink
ecosystem and extended functionality via [extensions](#extensions). Although vim-roam does
not explicitly require an outer wiki plugin, it is **highly recommended** you use
[wiki.vim](https://github.com/lervag/wiki.vim/). This is the only wiki plugin vim-roam is
guaranteed to work with; it has _not_ been tested with
[vimwiki](https://github.com/vimwiki/vimwiki).

**Note<sup>2</sup>**: while this plugin is part of my own note taking setup in Vim (and
runs smoothly on my system), it is still in early development and may not work perfectly
for you. You may or may not experience unexpected behavior depending on your filetypes or
note syntax. The plugin also does not have the level of configuration I would like at this
time, meaning it may not be easy to integrate with your wiki setup using the available
options. While large bugs will be fixed as they're uncovered and the available options
will mature in the future, do not expect things to work perfectly out of the box in its
current state. If you have any feedback/suggestions/bugs/etc, please feel free to open an
issue or initiate a pull request. Contributions are very much welcome!

## Table of contents
- [Installation](#installation)
- [Demo](#demo)
- [Read before using](#read-before-using)
- [Setup and options](#setup-and-options)
- [Usage](#usage)
- [Extensions](#extensions)
- [Why you shouldn't use Vim-roam](#why-you-shouldnt-use-vim-roam)

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
You will also need the latest version of
[Pandoc](https://github.com/jgm/pandoc/releases/tag/2.14.2) (v2.14.1 for the current
release) installed and available on your PATH. Note that if you have any trouble getting
Pandoc working on your system, you should be able to easily install it via the `pypandoc`
package (a dependency installed in the Python requirements). Check the [PyPI
page](https://pypi.org/project/pypandoc/) for more details.

# Demo
The following gif shows basic usage of the backlink buffer:

![Basic usage](screens/vim-roam-faster.gif)


# Read before using

## Wiki filetypes
As of right now, `vim-roam` only works with the Markdown filetype. This is because
vim-roam uses Pandoc's `commonmark` parser to get block-level context surrounding
wikilinks. This ensures vim-roam's file parsing can remain up-to-date with an official
parser in line with the Markdown spec (as opposed to a custom Vimscript solution). This
said, the explicit Markdown requirement can likely be relaxed (a current TODO), as the
parser only interfaces with basic lists, headers, and paragraph objects, which are common
across many wiki syntax variants.

## Default link syntax
Before using vim-roam, it's important to determine the wikilink syntax you're employing in
your notes. Wikipedia's [wikilink style](https://en.wikipedia.org/wiki/Help:Link) has
become popular and is used in `wiki.vim`, making it the obvious choice for the supported
default style in Vim-roam. The following shows a few possible forms for wikilinks of this
style:

```markdown
[[<URL>]]
[[<URL>|<display text>]]
[[<URL>#<anchor>]]
[[<URL>#<anchor>|<display text>]]
```

The brackets `[[` and `]]` enclose a target filename (the `<URL>`, without a file
extension) being referenced. Optional display text can be specified after a vertical bar
`|`, indicating how the link should be seen (either in Vim using conceal or in converted
filetypes like HTML). An optional anchor link can also be specified with a `#` following
the `<URL>`, indicating a target section _within_ the file being referenced. Any combination
of these options, as seen above, will be recognized by vim-roam. As mentioned, `wiki.vim`
supports this same syntax, and can navigate between files and sections in your wiki when
hitting `<enter>` while hovering over a wikilink.

## Alternative syntax and link transformations
Things are simple if your wikilinks use the real underlying filename of the target instead
of some transformation. That is, if linking to `my_file.md` in one of your wiki pages
looks as follows,

```markdown
This link to [[my_file]] works, and so does [[my_file|My File]].
```

then you don't need to configure any additional settings to ensure your filenames are
indexed appropriately. If you instead prefer a wikilink style that doesn't follow the
above standard, you will need to to assign a Vimscript function to the `g:roam_file2link`
variable in your `.vimrc` that captures how filenames are transformed into link text in
your wiki. For example, I personally prefer having my wikilinks natively look closer to
prose without using a `|` and additional text. That is, for the file `long_file_name.md`,
I would link to this file using

```markdown
Here's a link to a [[long file name]]
```

i.e. using spaces in place of underscores. My `g:roam_file2link` function describes this
transformation with the simple substitution `substitute(<fname>, '_', ' ', 'g')`. This
tells Vim-roam how links will look for a given filename across the wiki. This
transformation can be pretty much anything you'd like it to be, so long as it's a
one-to-one mapping from filenames to links.

### Working with `wiki.vim`
Even further down the link transformation rabbit hole: if you want to be able to navigate
between files when using an alternative link syntax (like that seen above), you need an
outer wiki plugin that supports it. To possibly save you some time scouring `wiki.vim`'s
documentation, there are two key options you can set to to customize how links are
followed:

- `g:wiki_map_create_page`: the function set to this variable will be used to transform
  text to a filename before opening the page. This is exclusively called in the
  `wiki#page#open()` method, which is primarily invoked when opening or creating new pages
  using the `<leader>wn` mapping.
- `g:wiki_resolver`: resolves target filenames from link text. This applies when following
  links using `<cr>` through the link handler's `follow()` method. The function assigned
  to this variable will be called to produce the full output file path when given link
  text.

Setting these two options in accordance with your desired wikilink syntax will allow you
to natively follow links and open pages properly. One important point here, however:
`wiki.vim` will _not_ properly handle file renaming across your wiki as it scans and
replaces wikilinks. While you can specify how to transform link text to filenames, it does
not know the inverse mapping, meaning it will not know how files _appear as links across
your system_. While this may be fixed in the future, consider using my [development fork of
wiki.vim](https://github.com/samgriesemer/wiki.vim) if think this drawback may affect you.
There are configuration details in fork's README>

# Setup and options
There are a few basic options you will need to set prior to using vim-roam. If you are
using `wiki.vim`, please see the relevant section below instead.

- You will need to specify the path to your root wiki directory via the `g:roam_wiki_root`
  option in your `.vimrc`. This tells vim-roam where to recursively scan for files when
  indexing the link graph. 
- You can override the default cache path (set to `~/.cache/vim-roam`) with the
  `g:wiki_cache_root` option.
- You can control the default mappings vim-roam will set using the
  `g:roam_mappings_use_defaults` and `g:roam_mappings_global` options:
    * `g:roam_mappings_use_defaults`: if set to 0, none of the default mappings will be set.
      You can see the three mappings that are set by default in the `plugin/roam.vim` file.
    * `g:roam_mappings_global`: this option works exactly the same as its [wiki.vim
      analog](https://github.com/lervag/wiki.vim/blob/master/doc/wiki.txt#L552). If a
      dictionary of mappings is set to this variable, they will override the global mappings,
      regardless of the value of `g:roam_mappings_use_defaults`.
- Specify the filename-to-link transformation function in the `g:roam_file2link` option
  (see [above](#alternative-syntax-and-link-transformations) if you are confused). You
  should set this variable to the local function name as a string, e.g.

  ```vim
  let g:roam_file2link = 'FnameToString'
  
  function! FnameToString(fname)
    return substitute(a:fname,'_',' ','g')
  endfunction
  ```

  Note you don't need to worry about this if you are using the default wikilink syntax as
  outlined above.

## If using `wiki.vim`
If you are using `wiki.vim`, a few of the above options will be derived from your existing
`wiki.vim` configuration:

- `g:roam_wiki_root` will use the `wiki.vim` option `g:wiki_root` by default.
- If using [my wiki.vim fork][3], the `roam_file2link` option will use the
  `g:wiki_map_file2link` setting by default.

# Usage
The primary command exposed by vim-roam is `:RoamBacklinkBuffer`, and is by default
mapped to `<leader>wb`. This command/mapping will toggle the so-called "backlink buffer"
on and off

Once all dependencies are installed and options have been configured properly, using
Vim-roam is fairly straightforward. There are two primary commands:

- `:RoamBacklinkBuffer` (default mapping `<leader>wb`): toggles the so-called "backlink
  buffer" on and off. When toggled on, backlinks are loaded for the wiki file open in the
  current window.
- `:RoamUpdateBacklinkBuffer` (default mapping `<leader>wbr`): refreshes the backlink
  buffer. This is useful if the buffer ever needs to be manually refreshed e.g. after a
  window is closed, if `roam_auto_update` is disabled, etc.

**Note**: when `RoamBacklinkBuffer` is called for the first time on your system, Vim-roam
will have to build the graph of your wiki files from scratch. Your `wiki_root` will be
recursively scanned for Markdown files and 


Calling this command does the following:

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

- [vim-roam-search](https://github.com/samgriesemer/vim-roam-search): a set of useful FZF
  search mappings for navigating wiki content. Includes fuzzy searching wiki filenames,
  lines in wiki pages, exact searches in special files (namely PDFs) with `ripgrepall`,
  special search rules for users with hard wrapped text, etc. Opened files are passed
  through `wiki.vim`'s page opening function, allowing pages to be added to the navigation
  history. Matched files are also passed through `wiki.vim`'s `WikiFileOpen` method, which
  can be customized in your `.vimrc` for handling certain files. For example, this can be
  used to open a PDF file in a document viewer of choice directly from a search match.
- [vim-roam-task](https://github.com/samgriesemer/vim-roam-task): Taskwarrior integration
  in Markdown files. This is a fork of the [Taskwiki]() plugin that removes the upstream
  repo's dependency on Vimwiki (and replaces it with `wiki.vim`). This fork also adds note
  functionality to tasks, allowing you to automatically create wiki files associated with
  tasks and sync task metadata to Markdown headers.
- [vim-roam-md](https://github.com/samgriesemer/vim-roam-md): syntax highlighting for
  Markdown wiki files. This is a slightly modified fork of
  [vim-markdown](https://github.com/plasticboy/vim-markdown), adding concealment for
  wikilinks and highlighting of inline TeX blocks.

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

# Why you shouldn't use Vim-roam
While Vim-roam can help improve your wiki experience in Vim, there are a number of reasons
why Vim-roam may be not be for you:

- **Vim-roam is still in an early development stage**. I've mostly put this together in my
  free time as I've picked up Vimscript, and this plugin may not meet the level of quality
  you've come to expect from great plugin developers. The configuration options are
  minimal at this stage, and there's no formal documentation as of this point.
- **Vim-roam might be too restrictive** to work well with your wiki setup. As mentioned
  above, for the time being Vim-roam only operates on Markdown files. It might also be the
  case that Vim-roam can't accommodate your custom wikilink syntax.
- **You don't want to use** `wiki.vim`. Although not required, using `wiki.vim` makes things
  significantly easier when setting up vim-roam. `wiki.vim` _is_ required for many of the
  extensions. If you have another wiki plugin, working around the possible conflicts when
  using it with vim-roam may not be worth your time.
- **Sufficient backlink functionality is already available in other plugins**. `Vimwiki` and
  `wiki.vim` offer some backlink handling on their own. This is probably sufficient for
  most users, and you should look into what these plugins offer before deciding to use
  vim-roam.
- **Vim-roam can be slow**, or at least the initial indexing process, depending on your
  system or wiki size. Vim-roam uses a filter over Pandoc's `commonmark` parser to extract
  positional information inside the wiki documents, which can take time for large files or
  large wikis. Luckily, it's trivial to amortize the conversion costs after initially
  indexing notes, so bulk processing only takes place once. Still, the initial processing
  can take some time; for example, on my system it takes roughly 3 minutes to build the
  index for ~2500 pages from scratch.
