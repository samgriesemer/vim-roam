# Introduction
Vim-roam is a Vim plugin for exploring a note graph connected via wikilinks. The name
"vim-roam" takes from the popular note taking tool [Roam research][12], which is widely
considered to have popularized the notion of highly interconnected notes and an integrated
_backlink explorer_. The goal of this plugin is to make it easy to find relevant content
across local wiki files using a similar approach, namely writing context-rich backlink
content dynamically to a buffer.

**Note**: this plugin does not intend to replace an outer wiki management plugin such as
`wiki.vim`. It instead aims to complement these plugins by adding a richer backlink
ecosystem and extended functionality via [extensions](#extensions). Although vim-roam does
not explicitly require an outer wiki plugin, it is **highly recommended** you use
[wiki.vim][13]. This is the only wiki plugin vim-roam is guaranteed to work with; it has
_not_ been tested with [vimwiki][14].

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
    * [Vim](#vim)
    * [Python](#python)
    * [Pandoc](#pandoc)
- [Demo](#demo)
- [Read before using](#read-before-using)
    * [Wiki filetypes](#wiki-filetypes)
    * [Default link syntax](#default-link-syntax)
    * [Alternative syntax and link transformations](#alternative-syntax-and-link-transformations)
        + [Working with wiki.vim](#working-with-wiki-vim)
- [Setup and options](#setup-and-options)
    * [If using wiki.vim](#if-using-wiki-vim)
- [Usage](#usage)
- [Extensions](#extensions)
    * [Custom Roam-like settings](#custom-roam-like-settings)
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
Using a Vim plugin manager like [vim-plug][11], add the following to your `.vimrc`:

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
You will also need the latest version of [Pandoc][10] (v2.14.1 for the current release)
installed and available on your PATH. Note that if you have any trouble getting Pandoc
working on your system, you should be able to easily install it via the `pypandoc` package
(a dependency installed in the Python requirements). Check the [PyPI page][9] for more
details.

# Demo
![Basic usage](screens/vim-roam-faster.gif)

This shows basic navigation (with [vim-roam-search][1]) and opening the backlink buffer
using `<leader>wb`. Navigation between wiki files in the left split automatically updates
the backlink buffer in the right split.

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
your notes. Wikipedia's [wikilink style][8] has
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
replaces wikilinks. While you can specify how to transform link text to filenames,
`wiki.vim` does not know the inverse mapping, meaning it will not know how files _appear
as links across your system_. While this may be fixed in the future, consider using my
[development fork of wiki.vim][7] if you think this
drawback may affect you. There are configuration details in fork's README.

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
      You can see the mappings that are set by default in the `plugin/roam.vim` file (also
      explained in [Usage](#usage))
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
- Automatic buffer reloading on `BufWinEnter` can be disabled by setting
  `g:roam_auto_update` to 0.

## If using `wiki.vim`
If you are using `wiki.vim`, a few of the above options will be derived from your existing
`wiki.vim` configuration:

- `g:roam_wiki_root` will use the `wiki.vim` option `g:wiki_root` by default.
- If using [my wiki.vim fork][7], the `roam_file2link` option will use the
  `g:wiki_map_file2link` setting by default.

# Usage
Once all dependencies are installed and options have been configured properly, using
Vim-roam is fairly straightforward. There are two primary commands:

- `:RoamBacklinkBuffer` (default mapping `<leader>wb`): toggles the so-called "backlink
  buffer" on and off. When toggled on, backlinks are loaded for the wiki file open in the
  current window.
- `:RoamUpdateBacklinkBuffer` (default mapping `<leader>wbr`): refreshes the backlink
  buffer. This is useful if the buffer ever needs to be manually refreshed e.g. after a
  window is closed, if `roam_auto_update` is disabled, etc.

**Note**: when `RoamBacklinkBuffer` is called for the first time on your system, Vim-roam
will have to build the graph of your wiki files/links from scratch. Your `wiki_root` will
be recursively scanned for Markdown files, and file contents will be parsed by Pandoc's
`commonmark` parser. 

Wikilinks between files and relevant surrounding context is stored in a
graph object and written to disk. This process can take some time depending on your
machine and wiki size, and (for now) Vim must remain open until the process is completed.
This process is ran asynchronously, however, so you can continue to use Vim as it
finishes.

Once the initial processing of wiki content has completed, further updates will be fast
and incremental. Files will only be re-parsed if they've been modified since their last
parse time, and the cached graph is stored between Vim sessions. By default, when toggled
the backlink buffer will automatically reload as you navigate between wiki files, keeping
the content graph up-to-date as you make changes. This reloading process is asynchronous
and shouldn't get in the way of regular wiki operation.

The backlink buffer itself is not an actual file that can be saved. It operates purely as
a place to write backlink content; making edits to the buffer will not have any effect. We
chose to use a regular Vim buffer instead of other native Vim window types (like location
lists) to make it easy to see backlink content as it would look in your wiki. Blocks of
content are easy to distinguish and native syntax, folding, etc applies in the buffer as
it would elsewhere.

# Extensions
Even if you don't use vim-roam's backlink functionality, some of the available "extension"
plugins listed below might be useful. These plugins were created with vim-roam in mind,
but are mostly independent of the plugin beyond overlapping configuration (i.e. your
vim-roam settings are re-used in extension plugins).

- [vim-roam-search][1]: a set of useful FZF search mappings for navigating wiki content.
  Includes fuzzy searching wiki filenames, lines in wiki pages, exact searches in special
  files (namely PDFs) with `ripgrepall`, special search rules for users with hard wrapped
  text, etc. Opened files are optionally passed through `wiki.vim`'s page opening
  function, allowing pages to be added to the navigation history. Matched files are also
  passed through `wiki.vim`'s `WikiFileOpen` method, which can be customized in your
  `.vimrc` for handling certain files. For example, this can be used to open a PDF file in
  a document viewer of choice directly from a search match.
- [vim-roam-task][2]: Taskwarrior integration in Markdown files. This is a fork of the
  [Taskwiki][5] plugin that removes the upstream repo's dependency on Vimwiki (and
  replaces it with `wiki.vim`). This fork also adds note functionality to tasks, allowing
  you to automatically create wiki files associated with tasks and sync task metadata to
  Markdown headers.
- [vim-roam-md][3]: syntax highlighting for Markdown wiki files. This is a slightly
  modified fork of [vim-markdown][4], adding concealment for wikilinks and highlighting of
  inline TeX blocks.

## Custom Roam-like settings
In the case you're interesting in extra settings that might improve your wiki experience,
consider taking a look at my current [.vimrc][6]. This file is constantly changing and by
no means the "right" settings. However, there may be a few useful settings for `wiki.vim`
or one of the above extension plugins that you'd like to replicate in your own setup. For
example, when creating journal pages using `wiki.vim`, I specify an empty path to place
pages in the same flat directory as all other wiki files. There are also a number of
wikilink transformation methods for `wiki.vim` that might give you a good place to start
for your own wikilink syntax.

# Why you shouldn't use Vim-roam
While Vim-roam can help improve your wiki experience in Vim, there are a number of reasons
why Vim-roam may not be for you:

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

[1]: https://github.com/samgriesemer/vim-roam-search
[2]: https://github.com/samgriesemer/vim-roam-task
[3]: https://github.com/samgriesemer/vim-roam-md
[4]: https://github.com/plasticboy/vim-markdown
[5]: https://github.com/tools-life/taskwiki
[6]: https://github.com/samgriesemer/templates/blob/master/vim/.vimrc
[7]: https://github.com/samgriesemer/wiki.vim
[8]: https://en.wikipedia.org/wiki/Help:Link
[9]: https://pypi.org/project/pypandoc/
[10]: https://github.com/jgm/pandoc/releases/tag/2.14.2
[11]: https://github.com/junegunn/vim-plug
[12]: https://roamresearch.com
[13]: https://github.com/lervag/wiki.vim/
[14]: https://github.com/vimwiki/vimwiki
