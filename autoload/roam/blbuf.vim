let s:wroot = expand(g:wiki_root)
let s:croot = expand(g:roam_cache_root)
let s:plugin_path = escape(expand('<sfile>:p:h:h:h'), '\')

" probably not best with slash, but should work
"let s:blbufnr = bufnr(s:croot.'/backlinkbuffer.1234', 1)
let s:blbufnr = bufnr('backlink-buffer.1234', 1)

function! roam#blbuf#post_async(n)
    "cclose 
    let l:out = system('cd '.s:plugin_path.' && python3 -m vimroam.main '.s:wroot.' --no-update --name='.a:n)
    call bufload('backlink-buffer.1234')
    silent! execute "call deletebufline(".s:blbufnr.", 1, '$')"

    " shifts file down when writing line 0
    call appendbufline(s:blbufnr, 1, split(l:out, '\n'))
    silent! execute "call deletebufline(".s:blbufnr.", 1)"
    "call setpos('.', [s:blbufnr, 1, 1, 0])

    " reset user asr exit function
    "let g:asyncrun_exit = saved_exit
endfunction

function! roam#blbuf#open(name)
    let l:save_view = winsaveview()
    let l:save_win = win_getid()
    let l:win_list = win_findbuf(s:blbufnr)
    if empty(l:win_list)
        execute 'rightb vert '.s:blbufnr.'sb'
        "setlocal autoread
        setlocal noswapfile
        setlocal modifiable
        setlocal buftype=nofile
        setlocal filetype=markdown
        "call setpos('.', [s:blbufnr, 1, 1, 0])
        silent! execute "call deletebufline(".s:blbufnr.", 0, '$')"
        call appendbufline(s:blbufnr, 0, 'Updating backlinks...')
    endif
    "call winrestview(l:save_view)
    "if user has g:asycnrun_exit set, save it here
    "
    " On async exit, call populate buffer with output, close quickfix

    "let g:asyncrun_open = 8
    "let g:asyncrun_exit = 'call roam#blbuf#post_async("'.a:name.'")'
    "let g:asyncrun_exit = "edit ".s:croot."/backlinkbuffer.1234"
    "let g:asyncrun_exit = "echo huh"


    " can maybe set run exit to re open file, see if that works after

    " run main command, update wiki graph
    " TODO: somehow check if we're current updating the graph cache so we don't do it
    " twice when navigating...should be able to do stuff while it's loading; might be able
    " to store pid of asyncrun here, then pass it into this function. if still going then
    " return 
    let l:rid = asyncrun#run('', {
        \ 'mode': 'term',
        \ 'post': 'call roam#blbuf#post_async("'.a:name.'")',
        \ 'cwd': s:plugin_path,
        \ 'pos': 'bottom',
        \ 'rows': 10,
        \ 'focus': 0,
        \ 'close': 1
    \ }, 'python3 -m vimroam.main '.s:wroot.' -v')
    call win_gotoid(l:save_win)
    echo l:rid
    call appendbufline(s:blbufnr, 1, string(l:rid))

    "\ }, 'cd '.s:plugin_path.' && python3 -m vimroam.main '.s:wroot.' -v')

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

