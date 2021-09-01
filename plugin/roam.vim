" A networked wiki plugin for Vim
"
" Maintainer: Sam Griesemer
" Email:      samgriesemer@gmail.com
"


" Python version detection.
if has("python3")
  let g:roam_py='py3 '
  let g:roam_pyfile='py3file '
else
  echoerr "vim-roam requires Vim compiled with the Python3 support."
  finish
endif

" Initialize options
call roam#init#option('wiki_journal', {
      \ 'name' : '',
      \ 'frequency' : 'daily',
      \ 'date_format' : {
      \   'daily' : '%Y-%m-%d',
      \   'monthly' : '%Y-%m',
      \   'yearly' : '%Y',
      \ },
\})
call roam#init#option('wiki_map_text_to_file', 'util#str_to_fname')
call roam#init#option('wiki_map_link_to_file', 'util#str_to_fname')
call roam#init#option('wiki_map_text_to_link', '')
call roam#init#option('wiki_map_file_to_link', 'util#fname_to_str')
call roam#init#option('wiki_map_file_to_text', 'util#fname_to_str')
call roam#init#option('wiki_link_conceal', 0)
call roam#init#option('roam_cache_root', expand('~/.cache/vim-roam'))
call roam#init#option('wiki_mappings_local', {
    \ '<plug>(wiki-graph-find-backlinks)' : '<Leader>wlb',
    \ '<plug>(wiki-link-toggle)' : '<Leader>wlt',
    \ '<plug>(wiki-fzf-toc)' : '<leader>wt',
    \ '<plug>(wiki-page-toc)' : '<Leader>wpt',
    \ '<plug>(wiki-journal-toweek)' : '<Leader>wjt'
\ })


"let s:plugin_path = escape(expand('<sfile>:p:h:h'), '\')
"exec "set path+=".s:plugin_path
"execute g:roam_pyfile . s:plugin_path . '/vimroam/main.py'



" Initialize global commands
command! RoamBacklinkBuffer call roam#blbuf#toggle()

" RoamFzfFiles - search wiki filenames and go to file
command! -bang -complete=dir RoamFzfFiles
    \ call fzf#vim#files(g:wiki_root, fzf#vim#with_preview({'right':'100'}, 'down:70%:wrap'), <bang>0)

" RoamFzfLines - search lines in all wiki files and go to file. Following FZF
" session has a prefilled query using the first argument, which is a
" string used for the initial ripgrep exact search.
command! -bang -nargs=* RoamFzfLines
    "\ call roam#search#fzf_grep_preview(rg_base, shellescape(<q-args>), g:wiki_root, <q-args>, <bang>0)
    \ call roam#search#fzf_grep_preview(
    \   'cd '.g:wiki_root.' && '.rg_base,
    \   shellescape(<q-args>),
    \   '*',
    \   <q-args>,
    \   'wLines> ',
    \   '3..',
    \   <bang>0,
    \   'accept_line',
    \ )

" RoamFzfLinesFnames - search lines in all wiki files and go to file. Following FZF
command! -bang -nargs=* RoamFzfLinesFnames
    "\ call roam#search#fzf_grep_preview(rg_base, shellescape(<q-args>), g:wiki_root, <q-args>, <bang>0)
    \ call roam#search#fzf_grep_preview(
    \   'cd '.g:wiki_root.' && '.rg_base,
    \   shellescape(<q-args>),
    \   '*',
    \   <q-args>,
    \   'wLines+f> ',
    \   '1,3..',
    \   <bang>0,
    \   'accept_line',
    \ )

" RoamFzfFullLines - search lines in all wiki files and go to file. Following FZF
command! -bang -nargs=* RoamFzfFullLines
    \ call roam#search#fzf_grep_preview(
    \   'python3 ' . s:plugin_path . '/autoload/roam/search.py ' . g:wiki_root, 
    \   '',
    \   '',
    \   <q-args>,
    \   'wLines+L> ',
    \   '3..',
    \   <bang>0,
    \   'accept_line',
    \ )

" RoamFzfFullPages - search lines in all wiki files and go to file. Following FZF
command! -bang -nargs=* RoamFzfFullPages
    \ call roam#search#fzf_grep_preview(
    \   'python3 ' . s:plugin_path . '/autoload/roam/search.py ' . g:wiki_root . ' 1', 
    \   '',
    \   '',
    \   <q-args>,
    \   'wLines+P> ',
    \   '3..',
    \   <bang>0,
    \   'accept_line',
    \ )

"command! -bang -nargs=* RoamFzfLinesHard
    ""\ call roam#search#fzf_grep_preview(rg_base, shellescape(<q-args>), g:wiki_root, <q-args>, <bang>0)
    "\ call roam#search#fzf_grep_preview(
    "\   'cd '.g:wiki_root.' && '.rg_base.' -- %s || true',
    "\   shellescape(<q-args>),
    "\   '*',
    "\   <q-args>,
    "\   'wLines+H> ',
    "\   '1,3..',
    "\   <bang>0,
    "\   {
    "\       
    "\ )

"function! RipgrepFzf(query, fullscreen)
  "let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  "let initial_command = printf(command_fmt, shellescape(a:query))
  "let reload_command = printf(command_fmt, '{q}')
  "let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  "call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
"endfunction



" RoamFzfBacklinks - find backlinks for current file. Uses ripgrep to match
" exact filename link regex across all wiki lines, then prefill FZF session
" with filename.
command! -bang -nargs=* RoamFzfBacklinks
    \ call roam#search#fzf_grep_preview(rg_base,
    \   '"\[[^\]]*\]\((.*/)*'.expand('%:t:r').'(#[^\)]*)*\)"',
    \   g:wiki_root,
    \   expand('%:t:r'),
    \   'Backlinks> ',
    \   '4..',
    \   <bang>0)

" RoamFzfUnlinks - get fuzzy unlinked references related to current filename.
" Uses ripgrep to search all wiki lines for mentions of the filename, then
" prefills following FZF session with this name.
command! -bang -nargs=* RoamFzfUnlinks
    \ call roam#search#fzf_grep_preview(rg_base,
    \   '".*"',
    \   g:wiki_root,
    \   expand('%:t:r'),
    \   'Unlinks> ',
    \   '4..',
    \   <bang>0)


" Initialize mappings
nnoremap <silent> <plug>(roam-fzf-files)              :RoamFzfFiles<cr>
nnoremap <silent> <plug>(roam-fzf-lines)              :RoamFzfLines<cr>
nnoremap <silent> <plug>(roam-fzf-lines-fnames)       :RoamFzfLinesFnames<cr>
nnoremap <silent> <plug>(roam-fzf-full-lines)         :RoamFzfFullLines<cr>
nnoremap <silent> <plug>(roam-fzf-full-pages)         :RoamFzfFullPages<cr>
nnoremap <silent> <plug>(roam-backlink-buffer)        :RoamBacklinkBuffer<cr>
nnoremap <silent> <plug>(roam-update-backlink-buffer) :RoamUpdateBacklinkBuffer<cr>
nnoremap <silent> <plug>(roam-fzf-backlinks)          :RoamFzfBacklinks<cr>
nnoremap <silent> <plug>(roam-fzf-unlinks)            :RoamFzfUnlinks<cr>


" Apply default mappings
let s:mappings = index(['all', 'global'], g:wiki_mappings_use_defaults) >= 0
      \ ? {
      \ '<plug>(roam-fzf-files)':        '<leader>wf',
      \ '<plug>(roam-fzf-lines)':        '<leader>wl',
      \ '<plug>(roam-fzf-lines-fnames)': '<leader>wL',
      \ '<plug>(roam-fzf-full-lines)':   '<leader>wsl',
      \ '<plug>(roam-fzf-full-pages)':   '<leader>wsL',
      \ '<plug>(roam-backlink-buffer)':  '<leader>wb',
      \ '<plug>(roam-fzf-unlinks)':      '<leader>wu',
      \} : {}
call extend(s:mappings, get(g:, 'roam_mappings_global', {}))
call roam#init#apply_mappings_from_dict(s:mappings, '')


" Initialize autocommands
"autocmd BufReadPost *.md call roam#blbuf#update()


" Expressions
imap <expr> [[ fzf#vim#complete(fzf#wrap({
    \ 'source': 'cd '.g:wiki_root.' && find * \| sed -r "s/(.*)\..*/\1/"',
    \ 'reducer': function('util#handle_completed_link'),
    \ 'options': '--bind=ctrl-d:print-query --multi --reverse --margin 15%,0',
    \ 'right':    40}))
