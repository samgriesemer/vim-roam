"
" search.vim: search method utilities
"
" Author: Sam Griesemer
"
" NOTE: fzf#vim#preview() arguments
" - First argument: {'options': <options_dict>, 'right/left/up/down': '<perc>%'}
" - Second argument: 'right/left/up/down': <perc>% [for preview window location]
"

" define useful base values
let rg_base = 'rg --column --line-number --no-heading --color=always --smart-case'

" general fzf search with preview
function roam#search#fzf_grep_preview(cmd, pat, loc, qry, prm, nth, bng, snk)
    let spec = fzf#vim#with_preview({
    \       'options': [
    \           '--prompt', a:prm,
    \           '--ansi',
    \           '--extended',
    \           '--delimiter=:',
    \           '--nth='.a:nth,
    \           '--with-nth=1,2,4..',
    \           '--query='.a:qry,
    \           '--print-query',
    \           '--expect='.get(g:, 'wiki_fzf_pages_force_create_key', 'alt-enter'),
    \       ],
    \       'right': '100'
    \   }, 'down:70%:wrap')

    call extend(spec, {
    \       'dir': g:roam_wiki_root,
    \       'sink*': funcref('s:'.a:snk),
    \   })

    call fzf#vim#grep(a:cmd.' '.a:pat.' '.a:loc, 1, spec, a:bng)
endfunction

function! s:accept_line(lines) abort "{{{1
    " 1st arg: query (partial)
    " 2nd arg: special key if used, otherwise empty string
    " 3rd arg: matched line
    " If no matches, only the first 2 args
    if len(a:lines) < 2 | return | endif
    let l:fname = ''

    " if no matches for query or special key used
    if len(a:lines) == 2 || !empty(a:lines[1])
        let l:fname = a:lines[0] 
    else
        let l:comp = split(a:lines[2], ':')
        let l:fname = l:comp[0]
        let l:lnum  = l:comp[1]
    endif

    call wiki#page#open(l:fname)
    " can use `call cursor(lnum, col)` if get col info
    execute l:lnum
endfunction

function! s:accept_page(lines) abort "{{{1
  " from wiki.vim:
  " a:lines is a list with two or three elements. Two if there were no matches,
  " and three if there is one or more matching names. The first element is the
  " search query; the second is either an empty string or the alternative key
  " specified by g:wiki_fzf_pages_force_create_key (e.g. 'alt-enter') if this
  " was pressed; the third element contains the selected item.
  if len(a:lines) < 2 | return | endif

  if len(a:lines) == 2 || !empty(a:lines[1])
    call wiki#page#open(a:lines[0])
    sleep 1
  else
    let l:file = split(a:lines[2], ':')[0]
    execute 'edit ' . l:file
  endif
endfunction


