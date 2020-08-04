" A Roam research wiki plugin for Vim
"
" Maintainer: Sam Griesemer
" Email:      samgriesemer@gmail.com
"

" wiki.vim check and options
"if g:wiki_loaded == 1 | finish | endif
"
"" Initialize options
"call wiki#init#option('wiki_journal', {
"      \ 'name' : '',
"      \ 'frequency' : 'daily',
"      \ 'date_format' : {
"      \   'daily' : '%Y-%m-%d',
"      \   'weekly' : '%Y_w%V',
"      \   'monthly' : '%Y_m%m',
"      \ },
"\})

" Initialize global commands
command! RoamBacklinkBuffer call roam#graph#backlink_buffer()

" Initialize mappings
"nnoremap <silent> <plug>(wiki-backlink-buffer) :WikiBacklinkBuffer<cr>

