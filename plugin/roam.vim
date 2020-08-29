" A Roam research wiki plugin for Vim
"
" Maintainer: Sam Griesemer
" Email:      samgriesemer@gmail.com
"

" wiki.vim check and options
"if g:wiki_loaded == 1 | finish | endif
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
call roam#init#option('prose_links', 1)
" enables title transform for FZF, backlinks, renaming, etc; anywhere we need to generate
" links we should check this option and see if we should create prose links
call roam#init#option('wiki_map_create_page', 'util#str_to_fname')
call roam#init#option('wiki_map_file_to_title', 'util#fname_to_str')
call roam#init#option('wiki_map_link_create', '')

" Initialize global commands
command! RoamBacklinkBuffer call roam#graph#backlink_buffer()

" Initialize mappings
nnoremap <silent> <plug>(wiki-backlink-buffer) :WikiBacklinkBuffer<cr>

