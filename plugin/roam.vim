" A networked note management plugin for Vim
"
" Maintainer: Sam Griesemer
" Email:      samgriesemer@gmail.com
"


" Initialize options
call roam#init#option('roam_wiki_root', get(g:, 'wiki_root', ''))
call roam#init#option('roam_cache_root', expand('~/.cache/vim-roam'))
call roam#init#option('roam_file2link', get(g:, 'wiki_map_file2link', ''))
call roam#init#option('roam_mappings_use_defaults', 1)


" Initialize global commands
command! RoamBacklinkBuffer call roam#blbuf#toggle()
command! RoamUpdateBacklinkBuffer call roam#blbuf#update()

" RoamFzfBacklinks - find backlinks for current file. Uses ripgrep to match
" exact filename link regex across all wiki lines, then prefill FZF session
" with filename.
command! -bang -nargs=* RoamFzfBacklinks
    \ call roam#search#fzf_grep_preview(
    \   'cd '.g:roam_wiki_root.' && '.rg_base,
    \   '"\[[^\]]*\]\((.*/)*'.expand('%:t:r').'(#[^\)]*)*\)"',
    \   '',
    \   expand('%:t:r'),
    \   'Backlinks> ',
    \   '4..',
    \   <bang>0,
    \   'accept_line'
    \ )

" RoamFzfUnlinks - get fuzzy unlinked references related to current filename.
" Uses ripgrep to search all wiki lines for mentions of the filename, then
" prefills following FZF session with this name.
command! -bang -nargs=* RoamFzfUnlinks
    \ call roam#search#fzf_grep_preview(
    \   'cd '.g:roam_wiki_root.' && '.rg_base,
    \   '".*"',
    \   '*',
    \   expand('%:t:r'),
    \   'Unlinks> ',
    \   '4..',
    \   <bang>0,
    \   'accept_line',
    \ )


" Initialize mappings
nnoremap <silent> <plug>(roam-backlink-buffer)        :RoamBacklinkBuffer<cr>
nnoremap <silent> <plug>(roam-update-backlink-buffer) :RoamUpdateBacklinkBuffer<cr>
nnoremap <silent> <plug>(roam-fzf-backlinks)          :RoamFzfBacklinks<cr>
nnoremap <silent> <plug>(roam-fzf-unlinks)            :RoamFzfUnlinks<cr>


" Apply default mappings
" the following are applied if the user allows `all` or `global` defaults
let s:mappings = g:roam_mappings_use_defaults > 0
      \ ? {
      \ '<plug>(roam-backlink-buffer)': '<leader>wb',
      \ '<plug>(roam-fzf-backlinks)':   '<leader>wzb',
      \ '<plug>(roam-fzf-unlinks)':     '<leader>wzu',
      \} : {}

" any user set global mappings are overridden here
call extend(s:mappings, get(g:, 'roam_mappings_global', {}))

" mappings finally applied
call roam#init#apply_mappings_from_dict(s:mappings, '')


" Initialize autocommands
autocmd BufWinEnter *.md call roam#blbuf#update()
"autocmd WinEnter *.md call roam#blbuf#update()

