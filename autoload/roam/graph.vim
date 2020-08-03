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


" NEW FUNCTIONS
function! roam#graph#backlink_buffer()
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
    execute 'botright vnew '.wikiroot.'/temp.md'
    setlocal buftype=nofile
    setlocal filetype=markdown
    let i = 1
    for l:link in l:results
        call setline(i, '# '.l:link.filename)
        let i = i+1
        call setline(i, l:link.text)
        let i = i+len(l:link.text)
        call setline(i, '')
        let i = i+1
    endfor
  endif
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
          \ || l:start != getpos('''<')[1:2]
          \ || l:end[0] != getpos('''>')[1]
          \ | break | endif

    let l:current = l:current.parent
  endwhile

  return [l:start, l:end]
endfunction


