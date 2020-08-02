" A simple wiki plugin for Vim
"
" Maintainer: Karl Yngve Lervåg
" Email:      karl.yngve@gmail.com
"

function! wiki#url#wiki#parse(url) abort " {{{1
  let l:url = deepcopy(s:parser)

  " Extract anchor
  let l:anchors = split(a:url.stripped, '#', 1)
  let l:url.anchor = len(l:anchors) > 1 ? join(l:anchors[1:], '#') : ''
  let l:url.anchor = substitute(l:url.anchor, '#$', '', '')

  " Parse the file path relative to wiki root
  if empty(l:anchors[0])
    let l:fname = fnamemodify(a:url.origin, ':p:t:r')
  else
    let l:fname = l:anchors[0]
          \ . (l:anchors[0] =~# '/$' ? b:wiki.index_name : '')
  endif

  " Function for modifying the links themselves so we don't always have to be
  " so explicit; is the exact same code as is used to modify page names when using
  " WikiOpen
  let l:fname =
        \ !empty(g:wiki_map_create_page) && exists('*' . g:wiki_map_create_page)
        \ ? call(g:wiki_map_create_page, [l:fname])
        \ : l:fname

  " Determine the proper extension (if necessary)
  if index(g:wiki_filetypes
        \ + (exists('b:wiki.extension') ? [b:wiki.extension] : []),
        \ fnamemodify(l:fname, ':e')) < 0
    let l:fname .= '.' . (exists('b:wiki.extension')
          \ ? b:wiki.extension
          \ : g:wiki_filetypes[0])
  endif

  " Extract the full path
  let l:url.path = l:fname[0] ==# '/'
        \ ? wiki#get_root() . l:fname
        \ : (empty(a:url.origin)
        \   ? wiki#get_root()
        \   : fnamemodify(a:url.origin, ':p:h')) . '/' . l:fname
  let l:url.dir = fnamemodify(l:url.path, ':p:h')

  " Better path extraction: the l:fname confused me for some time, but it will
  " hold the proper relative URL that came out of the link (without anchors),
  " i.e. the base relative URL that we'd like to traverse. However it appears
  " that relative URLs are not always expanded properly. A simple call to
  " `fnamemodify` to get the full path seems to resolve this.
  let l:url.path = fnamemodify(l:url.path,':p')

  return l:url
endfunction

" }}}1

let s:parser = {}
function! s:parser.open(...) abort dict " {{{1
  let l:cmd = a:0 > 0 ? a:1 : 'edit'

  " Check if dir exists
  let l:dir = fnamemodify(self.path, ':p:h')
  if !isdirectory(l:dir)
    call mkdir(l:dir, 'p')
  endif

  " Open wiki file
  let l:same_file = resolve(self.path) ==# resolve(expand('%:p'))
  if !l:same_file
    if !empty(self.origin)
          \ && resolve(self.origin) ==# resolve(expand('%:p'))
      let l:old_position = [expand('%:p'), getpos('.')]
    elseif &filetype ==# 'wiki'
      let l:old_position = [self.origin, []]
    endif

    execute l:cmd fnameescape(self.path)

    if exists('l:old_position')
      let b:wiki = get(b:, 'wiki', {})
      call wiki#nav#add_to_stack(l:old_position)
    endif
  endif

  " Go to anchor
  if !empty(self.anchor)
    " Manually add position to jumplist (necessary if we in same file)
    if l:same_file
      normal! m'
    endif

    call self.open_anchor()
  endif

  " Focus
  if &foldenable
    if l:same_file
      normal! zv
    else
      normal! zx
    endif
  endif

  if exists('#User#WikiLinkOpened')
    doautocmd <nomodeline> User WikiLinkOpened
  endif
endfunction

"}}}1
function! s:parser.open_anchor() abort dict " {{{1
  let l:old_pos = getpos('.')
  call cursor(1, 1)

  for l:part in split(self.anchor, '#', 0)
    let l:part = substitute(l:part, '[- ]', '[- ]', 'g')
    let l:header = '^#\{1,6}\s*' . l:part . '\s*$'
    let l:bold = wiki#rx#surrounded(l:part, '*')

    if !(search(l:header, 'Wc') || search(l:bold, 'Wc'))
      call setpos('.', l:old_pos)
      break
    endif
    let l:old_pos = getpos('.')
  endfor
endfunction

" }}}1

