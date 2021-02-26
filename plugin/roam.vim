" A networked wiki plugin for Vim
"
" Maintainer: Sam Griesemer
" Email:      samgriesemer@gmail.com
"

" Initialize options
call roam#init#option('wiki_journal', {
      \ 'name' : '',
      \ 'frequency' : 'daily',
      \ 'date_format' : {
      \   'daily' : '%Y-%m-%d',
      \   'weekly' : '%Y_w%V',
      \   'monthly' : '%Y_m%m',
      \ },
\})
call roam#init#option('wiki_map_text_to_file', 'util#str_to_fname')
call roam#init#option('wiki_map_link_to_file', 'util#str_to_fname')
call roam#init#option('wiki_map_text_to_link', '')
call roam#init#option('wiki_map_file_to_link', 'util#fname_to_str')
call roam#init#option('wiki_map_file_to_text', 'util#fname_to_str')
call roam#init#option('wiki_link_conceal', 0)
call roam#init#option('wiki_mappings_local', {
    \ '<plug>(wiki-graph-find-backlinks)' : '<Leader>wlb',
    \ '<plug>(wiki-link-toggle)' : '<Leader>wlt',
    \ '<plug>(wiki-fzf-toc)' : '<leader>wt',
    \ '<plug>(wiki-page-toc)' : '<Leader>wpt',
    \ '<plug>(wiki-journal-toweek)' : '<Leader>wjt'
\ })


" Initialize global commands
command! RoamBacklinkBuffer call roam#graph#backlink_buffer()
command! RoamUpdateBacklinkBuffer call roam#graph#update_backlink_buffer()

" WikiFzfFiles - search wiki filenames and go to file
command! -bang -complete=dir RoamFzfFiles
    \ call fzf#vim#files(g:wiki_root, fzf#vim#with_preview({'right':'50%'}, 'down:50%:wrap'), <bang>0)

" WikiFzfLines - search lines in all wiki files and go to file. Following FZF
" session has a prefilled query using the first argument, which is a
" string used for the initial ripgrep exact search.
command! -bang -nargs=* RoamFzfLines
    \ call FzfGrepPreview(rg_base, shellescape(<q-args>), g:wiki_root, <q-args>, <bang>0)

" WikiFzfBacklinks - find backlinks for current file. Uses ripgrep to match
" exact filename link regex across all wiki lines, then prefill FZF session
" with filename.
command! -bang -nargs=* RoamFzfBacklinks
    \ call FzfGrepPreview(rg_base,
    \   '"\[[^\]]*\]\((.*/)*'.expand('%:t:r').'(#[^\)]*)*\)"',
    \   g:wiki_root,
    \   expand('%:t:r'),
    \   <bang>0)

" WikiFzfUnlinks - get fuzzy unlinked references related to current filename.
" Uses ripgrep to search all wiki lines for mentions of the filename, then
" prefills following FZF session with this name.
command! -bang -nargs=* RoamFzfUnlinks
    \ call FzfGrepPreview(rg_base,
    \   '".*"',
    \   g:wiki_root,
    \   expand('%:t:r'),
    \   <bang>0)

" Initialize mappings
nnoremap <silent> <plug>(roam-backlink-buffer) :RoamBacklinkBuffer<cr>
nnoremap <silent> <plug>(roam-update-backlink-buffer) :RoamUpdateBacklinkBuffer<cr>
nnoremap <silent> <plug>(roam-fzf-files) :RoamFzfFiles<cr>
nnoremap <silent> <plug>(roam-fzf-lines) :RoamFzfLines<cr>
nnoremap <silent> <plug>(roam-fzf-backlinks) :RoamFzfBacklinks<cr>
nnoremap <silent> <plug>(roam-fzf-unlinks) :RoamFzfUnlinks<cr>


" Apply default mappings
let s:mappings = index(['all', 'global'], g:wiki_mappings_use_defaults) >= 0
      \ ? {
      \ '<plug>(roam-backlink-buffer)' : '<leader>wb',
      \ '<plug>(roam-fzf-files)' : '<leader>wf',
      \ '<plug>(roam-fzf-lines)' : '<leader>wl',
      \ '<plug>(roam-fzf-unlinks)' : '<leader>wu',
      \} : {}
call extend(s:mappings, get(g:, 'roam_mappings_global', {}))
call roam#init#apply_mappings_from_dict(s:mappings, '')


" Initialize autocommands
autocmd BufReadPost *.md call roam#graph#update_backlink_buffer()

" Expressions
imap <expr> [[ fzf#vim#complete(fzf#wrap({
    \ 'source': 'cd '.g:wiki_root.' && find *',
    \ 'reducer': function('util#handle_completed_link'),
    \ 'options': '--bind=ctrl-d:print-query --multi --reverse --margin 15%,0',
    \ 'right':    40}))
