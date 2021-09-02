" Option initialization utilities, taken from wiki.vim
"
" See [here](https://github.com/lervag/wiki.vim/blob/master/autoload/wiki/init.vim) for
" original implementation by @lervag

function! roam#init#option(name, default) abort " {{{1
  let l:option = 'g:' . a:name
  let {l:option} = a:default

  if type(a:default) == type({})
    call roam#init#extend_recursive({l:option}, a:default, 'keep')
  endif
endfunction

function! roam#init#apply_mappings_from_dict(dict, arg) abort " {{{1
  for [l:rhs, l:lhs] in items(a:dict)
    if l:rhs[0] !=# '<'
      let l:mode = l:rhs[0]
      let l:rhs = l:rhs[2:]
    else
      let l:mode = 'n'
    endif

    if hasmapto(l:rhs, l:mode)
      continue
    endif

    execute l:mode . 'map <silent>' . a:arg l:lhs l:rhs
  endfor
endfunction

function! roam#init#extend_recursive(dict1, dict2, ...) abort " {{{1
  let l:option = a:0 > 0 ? a:1 : 'force'
  if index(['force', 'keep', 'error'], l:option) < 0
    throw 'E475: Invalid argument: ' . l:option
  endif

  for [l:key, l:value] in items(a:dict2)
    if !has_key(a:dict1, l:key)
      let a:dict1[l:key] = l:value
    elseif type(l:value) == type({})
      call wiki#u#extend_recursive(a:dict1[l:key], l:value, l:option)
    elseif l:option ==# 'error'
      throw 'E737: Key already exists: ' . l:key
    elseif l:option ==# 'force'
      let a:dict1[l:key] = l:value
    endif
    unlet l:value
  endfor

  return a:dict1
endfunction
