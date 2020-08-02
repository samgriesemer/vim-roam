# Introduction

This is a custom fork of Lervag's fanstastic
[wiki.vim](https://github.com/lervag/wiki.vim) plugin. This was created to address
(mainly personal) problems I have with built-in functionality of the plugin, as well as
extend it to enable [Roam research](https://roamresearch.com/)-like functionality:

1. (Bug) Broken relative link navigation for wiki links. I want my link targets to be
   relative to the current file for consistency and to ensure HTML conversion used
   relative links.  While this works in some instances, when a link needs to go to a
   parent directory the plugin incorrectly appends the relative link to the end of an
   absolute link. For example,

    ```
    This is a relative [link](../dir2/other.md) inside `dir1/file.md`. When <cr> is hit,
    wiki.vim attempts to go to the file `dir1/../dir2/other.md` literally, without
    properly expanded the relativel `..`.
    ```

   This problem is solved by simply calling the `realpath` utility to expand any relative
   path into the proper absolute path. There may be a better way to do this without
   calling a shell command, but for now this seems to do the job.
1. (Feature) Improved backlink functionality.
2. Added `g:write_on_follow` options to automatically save the current buffer before
   following a link (avoiding the consistent error message in favor of habit)
3. (Future feature) Flexible link schema for going to any line or column in any file. This
   will allow backlinks to go directly to lines that aren't anchors, and allow references
   to any line across the wiki (like [Roam](https://roamresearch.com/)'s embed feature).
   Such a link schema is not supported by Markdown itself, and can't be replicated in HTML
   easily (both just allow anchor links to headers at best), but it could be useful
   in-system functionality.

