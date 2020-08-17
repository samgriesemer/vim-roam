function! roam#init#option(name, default) abort " {{{1
  let l:option = 'g:' . a:name
  let {l:option} = a:default

  if type(a:default) == type({})
    call wiki#u#extend_recursive({l:option}, a:default, 'keep')
  endif
endfunction

