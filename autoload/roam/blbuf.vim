let s:wroot = expand(g:wiki_root)
let s:croot = expand(g:roam_cache_root)
let s:plugin_path = escape(expand('<sfile>:p:h:h:h'), '\')

let s:run_flag = 0
let s:cur_name = ''

" probably not best with slash, but should work
"let s:blbufnr = bufnr(s:croot.'/backlinkbuffer.1234', 1)
let s:blbufnr = bufnr('backlink-buffer.1234', 1)

function! roam#blbuf#post_async(n)
    let l:out = system('cd '.s:plugin_path.' && python3 -m vimroam.main '.s:wroot.' --no-update --name='.a:n)
    call bufload('backlink-buffer.1234')
    silent! execute "call deletebufline(".s:blbufnr.", 1, '$')"

    " shifts file down when writing line 0
    call appendbufline(s:blbufnr, 1, ['== Backlinks for '.a:n.' ==', ''])
    silent! execute "call deletebufline(".s:blbufnr.", 1)"

    if empty(trim(l:out))
        let l:out = 'No backlinks found for '.a:n
    endif

    call appendbufline(s:blbufnr, 2, split(l:out, '\n'))

    " unset run flag
    let s:run_flag = 0
endfunction

function! roam#blbuf#open(name)
    let l:save_win = win_getid()
    let l:win_list = win_findbuf(s:blbufnr)
    if empty(l:win_list)
        execute 'rightb vert '.s:blbufnr.'sb'
        if str2nr(&textwidth) > 0
            execute 'vertical resize '.string(str2nr(&textwidth)+8)
        endif
        setlocal noswapfile
        setlocal modifiable
        setlocal buftype=nofile
        setlocal filetype=markdown
    else
        " focus on backlink window briefly
        call win_gotoid(l:win_list[0])
    endif

    silent! execute "call deletebufline(".s:blbufnr.", 1, '$')"
    call appendbufline(s:blbufnr, 1, 'Updating backlinks...')
    silent! execute "call deletebufline(".s:blbufnr.", 1)"

    if s:run_flag
        "echo "(Currently scanning backlinks, new process not spawned)"
        call appendbufline(s:blbufnr, 1, 'Page changed to '.a:name.', backlink target still set to original page '.s:cur_name)
        call win_gotoid(l:save_win)
        " possibly print target so we know what backlinks _will_ show even if file is
        " changed
        return
    endif

    let s:run_flag = 1
    let s:cur_name = a:name
    " run main command, update wiki graph
    " TODO: somehow check if we're current updating the graph cache so we don't do it
    " twice when navigating...should be able to do stuff while it's loading; might be able
    " to store pid of asyncrun here, then pass it into this function. if still going then
    " return 
    call asyncrun#run('', {
        \ 'mode': 'term',
        \ 'post': 'call roam#blbuf#post_async("'.a:name.'")',
        \ 'cwd': s:plugin_path,
        \ 'pos': 'bottom',
        \ 'rows': 10,
        \ 'focus': 0,
        \ 'close': 1
    \ }, 'python3 -m vimroam.main '.s:wroot.' -v')

    " restore previous window
    call win_gotoid(l:save_win)

    "call asyncrun#run('', {'mode': 'term', 'post': 'call roam#blbuf#post_async("'.a:name.'")'}, 'cd /home/smgr/.vim/plugged/vim-roam/ && python3 -m vimroam.main '.s:wroot.' --verbose --write --name='.a:name)
    "opting for full term mode?
    "execute "AsyncRun -mode=term -post=call\\ roam\\#blbuf\\#post_async('".a:name."')  cd /home/smgr/.vim/plugged/vim-roam/ && python3 -m vimroam.main ".s:wroot." -v"
endfunction

function! roam#blbuf#close()
    let l:win_list = eval('win_findbuf('.s:blbufnr.')')
    if !empty(l:win_list)
        let l:win_num = eval('win_id2win('.win_list[0].')')
        execute win_num.'wincmd c'
    endif
endfunction

let s:bltoggle = 0
function! roam#blbuf#toggle()
    if s:bltoggle
        call roam#blbuf#close()
        let s:bltoggle = 0
    else
        call roam#blbuf#open(expand('%:t:r'))
        let s:bltoggle = 1
    endif
endfunction

function! roam#blbuf#update()
    if s:bltoggle
        call roam#blbuf#open(expand('%:t:r'))
    endif
endfunction

