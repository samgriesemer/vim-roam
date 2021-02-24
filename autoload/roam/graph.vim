" A simple wiki plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

" custom: extended backlink functionality, define two new functions:
"
" 1. s:list_bounds(): get (lnum, col) bounds of current list item, used by
"    BacklinkBuffer to understand the full range of the current list item scope
"    (instead of just getting the one line where the link is)
" 2. BacklinkBuffer(): push backlinks and their full `il` text object context to a new
"    buffer. In my opinion, this is far better than using a location list, as you get
"    your markdown settings to display the text and it improves visibility of content
"    significantly.
"
" Defines a new `BacklinkBuffer` command in plugin/wiki.vim.

let s:blbufnr=''

function! roam#graph#backlink_buffer()
  " check for graph attribute in wiki object of current buffer
  if !has_key(b:wiki, 'graph')
    let b:wiki.graph = s:graph.init()
  endif

  let l:origin = s:file_to_node(expand('%:p'))
  let l:results = b:wiki.graph.links_to(l:origin)

  " save relevant position details
  let l:save_pos = getcurpos()
  let l:save_buf = bufnr('%')
  for l:link in l:results
    let l:link.filename = l:link.filename_from
    "let l:link.text = readfile(l:link.filename, 0, l:link.lnum)[-1]
    
    " need to set the position in the appropriate file to allow list
    " element text object to get the proper bounds for that list
    " object. Set the current position using the known file buffer and the
    " appropriate lnum.
    let bnr = bufnr(l:link.filename, 1)
    execute 'buffer '.bnr

    " can't _actually_ switch buffers with setpos
    call setpos('.', [0, l:link.lnum, 1, 0])
    let lnums = s:list_bounds()
    let l:link.lnums = lnums

    if !empty(lnums)
        let l:link.text = readfile(l:link.filename, 0, lnums[1][0])[(lnums[0][0]-1):]
    else
        let l:link.text = readfile(l:link.filename, 0, l:link.lnum)[-1:]
    endif
    "execute 'bd '.bnr
  endfor
  call setpos('.', l:save_pos)
  execute 'buffer '.l:save_buf

  if empty(l:results)
    echomsg 'wiki: No other file links to this file'
  else
    let wikiroot = wiki#get_root()
    " also check if buffer still open (don't continue if user :q it) 
    if empty(win_findbuf(s:blbufnr))
        execute 'botright vnew '.wikiroot.'/temp.md'
        let s:blbufnr = bufnr('%')
        setlocal buftype=nofile
        setlocal filetype=markdown
    endif

    let i = 1
    let cur_page = ''
    for l:link in l:results
        " group same-page results under same header
        if cur_page != l:link.node_from
            let title = call(g:wiki_map_file_to_title, [l:link.node_from])
            call setbufline(s:blbufnr, i, '# '.title.' ([['.title.']])')
            let cur_page = l:link.node_from
            let i = i+1
        endif
        call setbufline(s:blbufnr, i, l:link.text)
        let i = i+len(l:link.text)
        call setbufline(s:blbufnr, i, '')
        let i = i+1
    endfor
    " clear end of buffer
    call deletebufline(s:blbufnr, i, '$')
  endif
endfunction

function! roam#graph#update_backlink_buffer()
    if (!empty(win_findbuf(s:blbufnr))) && (bufnr('%') != s:blbufnr)
        call roam#graph#backlink_buffer()
    endif
endfunction

function! roam#graph#testli()
  let [l:root, l:current] = wiki#list#get()
  if empty(l:current)
    return []
  endif

  while v:true
    let l:start = [l:current.lnum_start, 1]
    let l:end = [l:current.lnum_end_children(), 1]
    let l:end[1] = strlen(getline(l:end[0]))
    let l:linewise = 1

    if l:current.type ==# 'root'
          "\ || l:start != getpos('''<')[1:2]
          "\ || l:end[0] != getpos('''>')[1]
          \ || match(getline(l:start[0]),'\S') == 0
          \ | break | endif

    let l:current = l:current.parent
  endwhile

  return [l:start, l:end]
endfunction

function! s:list_bounds()
  let [l:root, l:current] = wiki#list#get()
  if empty(l:current)
    return []
  endif

  while v:true
    let l:start = [l:current.lnum_start, 1]
    let l:end = [l:current.lnum_end_children(), 1]
    let l:end[1] = strlen(getline(l:end[0]))
    let l:linewise = 1

    if l:current.type ==# 'root'
          "\ || l:start != getpos('''<')[1:2]
          "\ || l:end[0] != getpos('''>')[1]
          \ || match(getline(l:start[0]),'\S') == 0
          \ | break | endif

    let l:current = l:current.parent
  endwhile

  return [l:start, l:end]
endfunction




" from original plugin

let s:graph = {}

function! s:graph.init() abort dict " {{{1
  let new = deepcopy(s:graph)
  unlet new.init

  let new.nodes = s:gather_nodes()

  return new
endfunction

" }}}1
function! s:graph.links_from(node) abort dict " {{{1
  return deepcopy(get(get(self.nodes, a:node, {}), 'links', []))
endfunction

" }}}1
function! s:graph.links_to(node) abort dict " {{{1
  return deepcopy(get(get(self.nodes, a:node, {}), 'linked', []))
endfunction

" }}}1

function! s:gather_nodes() abort " {{{1
  if has_key(s:nodes, b:wiki.root)
    return s:nodes[b:wiki.root]
  endif

  redraw
  echohl ModeMsg
  echo 'wiki: Scanning wiki graph nodes ... '
  echohl NONE
  sleep 25m

  let l:cache = wiki#cache#open('graph', {
        \ 'local': 1,
        \ 'default': { 'ftime': -1 },
        \})

  let l:gathered = {}
  for l:file in globpath(b:wiki.root, '**/*.' . b:wiki.extension, 0, 1)
    let l:node = s:file_to_node(l:file)

    let l:current = l:cache.get(l:file)
    let l:ftime = getftime(l:file)
    if l:ftime > l:current.ftime
      let l:cache.modified = 1
      let l:current.ftime = l:ftime
      let l:current.links = []
      for l:link in filter(wiki#link#get_all(l:file),
            \ 'get(v:val, ''scheme'', '''') ==# ''wiki''')
        call add(l:current.links, {
              \ 'node_from' : l:node,
              \ 'node_to' : s:file_to_node(l:link.path),
              \ 'filename_from' : l:file,
              \ 'filename_to' : resolve(l:link.path),
              \ 'text' : get(l:link, 'text'),
              \ 'anchor' : l:link.anchor,
              \ 'lnum' : l:link.lnum,
              \ 'col' : l:link.c1
              \})
      endfor
    endif

    let l:gathered[l:node] = l:current
  endfor

  " Save cache
  call l:cache.write()

  for l:node in values(l:gathered)
    let l:node.linked = []
  endfor

  for l:node in values(l:gathered)
    for l:link in l:node.links
      if has_key(l:gathered, l:link.node_to)
        call add(l:gathered[l:link.node_to].linked, l:link)
      endif
    endfor
  endfor

  echohl ModeMSG
  echon 'DONE'
  echohl NONE

  let s:nodes[b:wiki.root] = l:gathered
  return l:gathered
endfunction

let s:nodes = {}

" }}}1
function! s:file_to_node(file) abort " {{{1
  return fnamemodify(a:file, ':t:r')
endfunction

" }}}1

