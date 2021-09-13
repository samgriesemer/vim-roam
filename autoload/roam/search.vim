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
function roam#search#fzf_grep_preview(cmd, pat, loc, qry, prm, nth, bng, pny, snk, ...)
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
    \           '--expect=ctrl-x,ctrl-v,'.get(g:, 'wiki_fzf_pages_force_create_key', 'alt-enter'),
    \       ]})

    "       'right': '100'
    "   }, 'down:70%:wrap')
    
    if a:pny
        call add(spec.options, '--phony')
    endif

    if a:0 > 0
        "let spec = extend(spec, a:1)
        let pos = index(spec['options'], '--preview')
        let spec.options[pos+1] = a:1
    endif
    if a:0 > 1
        let pos = index(spec['options'], '--bind')
        let spec.options[pos+1] = a:2
    end

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
    " ignore special key for now since it seems phony only outputs 2 params + we dont care
    " about special handling on lies
    if len(a:lines) == 2 || !empty(a:lines[1])
        let l:fname = a:lines[0]
        return
        "let l:comp = split(a:lines[1], ':')
    endif

    let l:comp = split(a:lines[2], ':')
    let l:fname = l:comp[0]
    let l:lnum  = l:comp[1]
    let l:page = 1

    " for certain docs rga will place "Page x" within doc preview, giving page number in
    " match line
    if len(l:comp) >= 4
        if match(l:comp[3], '^Page \d\+$') == 0
            let l:page = substitute(l:comp[3], '^Page \(\d\+\)$', '\1', '')
        endif
    endif

    try
        if call(get(g:, 'wiki_file_handler', ''), [], {'path':l:fname,'page':l:page})
            return
        endif
    catch /E117:/
      " Pass
    endtry

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

    let l:target = ''
    let l:cmd = ''

    if len(a:lines) == 2
        " no matches, set page text to query text
        let l:target = a:lines[0]
    else
        " handle specific keys
        let l:target = a:lines[2]

        if a:lines[1] == 'ctrl-x'
            " regular vim split
            let l:cmd = 'split'

        elseif a:lines[1] == 'ctrl-v'
            " vertical vim split
            let l:cmd = 'vsplit'

        elseif !empty(a:lines[1])
            " some other key recognized, set to query
            let l:target = a:lines[0]

        else
            " regular match, first pass through wiki.vim's file_handler
            try
                if call(get(g:, 'wiki_file_handler', ''), [], {'path':l:target})
                    return
                endif
            catch /E117:/
              " Pass
            endtry
        endif
    endif
    
    " finally open with wiki.vim, optionally w command
    if !empty(l:cmd)
        call wiki#page#open(l:target, l:cmd)
    else
        call wiki#page#open(l:target)
    endif
endfunction


