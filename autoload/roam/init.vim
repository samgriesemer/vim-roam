function! roam#init#option(name, default) abort " {{{1
  let l:option = 'g:' . a:name
  let {l:option} = a:default

  if type(a:default) == type({})
    call wiki#u#extend_recursive({l:option}, a:default, 'keep')
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
