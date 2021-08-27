let s:wroot = expand(g:wiki_root)
let s:blbufnr = bufnr('backlink-buffer.1234', 1)

function! roam#blbuf#post_async(n)
    cclose 
    let l:out = system('cd /home/smgr/.vim/plugged/vim-roam/ && python3 -m vimroam.main '.s:wroot.' --no-update --name='.a:n)
    call bufload('backlink-buffer.1234')
    silent! execute "call deletebufline(".s:blbufnr.", 1, '$')"
    call appendbufline(s:blbufnr, 0, split(l:out, '\n'))

    " reset user asr exit function
    "let g:asyncrun_exit = saved_exit
endfunction

function! roam#blbuf#open(name)
    let l:win_list = win_findbuf(s:blbufnr)
    if empty(l:win_list)
        execute 'rightb vert '.s:blbufnr.'sb'
        setlocal noswapfile
        setlocal modifiable
        setlocal buftype=nofile
        setlocal filetype=markdown
    endif
    "if user has g:asycnrun_exit set, save it here
    "
    " On async exit, call populate buffer with output, close quickfix

    let g:asyncrun_open = 8
    let g:asyncrun_exit = 'call roam#blbuf#post_async("'.a:name.'")'

    " run main command, update wiki graph
    " TODO: somehow check if we're current updating the graph cache so we don't do it
    " twice when navigating...should be able to do stuff while it's loading
    call asyncrun#run('', {'mode': 'async'}, 'cd /home/smgr/.vim/plugged/vim-roam/ && python3 -m vimroam.main '.s:wroot.' -v')
    "opting for full term mode?
    "execute "AsyncRun -mode=term -post=call\\ roam\\#blbuf\\#post_async('".a:name."')  cd /home/smgr/.vim/plugged/vim-roam/ && python3 -m vimroam.main '".s:wroot."' -v'"
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

