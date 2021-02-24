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

" Initialize global commands
command! RoamBacklinkBuffer call roam#graph#backlink_buffer()
command! RoamUpdateBacklinkBuffer call roam#graph#update_backlink_buffer()

" Initialize mappings
nnoremap <silent> <plug>(roam-backlink-buffer) :RoamBacklinkBuffer<cr>
nnoremap <silent> <plug>(roam-update-backlink-buffer) :RoamUpdateBacklinkBuffer<cr>

" Initialize autocommands
autocmd BufReadPost *.md call roam#graph#update_backlink_buffer()

