" Format system compatible filename from string. This replaces spaces with
" underscores in the filename, 
function! util#str_to_fname(str)
    " replace spaces with underscores
    let fname = substitute(a:str,' ','_','g')

    " replace special chars (?!%$, etc)
    return fname
endfunction

function! util#fname_to_str(fname)
    " replace underscores with spaces
    let str = substitute(a:fname,'_',' ','g')

    " replace special chars (?!%$, etc)
    return str
endfunction

" Take a path (can be absolute or relative), and return a relative path to that file from
" the current file. Operates on the assumption that any relative paths passed in will be
" relative to the wiki root, and any absolute paths must include the wiki root (i.e. be
" referencing a file actually in the wiki).
function! util#rel_path_from_file(path)
    " if path is absolute and has head mathcing wiki root (as it must if it's a full path;
    " else it's outside the wiki), then remove the wiki path substring for convenience
    let wiki_root = expand(g:wiki_root)
    let path = substitute(expand(a:path),wiki_root,'','')

    " <path> will be relative to wiki root
    let fullpath = wiki_root.'/'.path

    let pathcmd = 'realpath '.fullpath.' --relative-to '.expand('%:p:h')
    let newpath = system(pathcmd)
    let newpath = substitute(newpath,'\n','','g')

    " handle absolute wiki file path for local directories
    if newpath[:2] == "./"
        let newpath = newpath[2:]
    endif

    return newpath
endfunction

" Autocomplete links (fills dashes with spaces, underscores with dots) Can be
" 1) no path, just filename. Returned string will remain local (i dont get why this is
" listed, it's never this way)
" 2) subsystem path relative to the system root e.g. 'wiki/name.md' or 'feed/name.md'
"    In this case returned path will be relative to current file
"
" Takes a
function! util#wrap_link(path)
    " decouple base path (head) from filename
    let head = fnamemodify(a:path, ':h')
    let fname = fnamemodify(a:path, ':t')

    " manually strip .md to ensure names with dots aren't affected
    let fname = substitute(fname,'\.md','','')

    " ensure filename meets naming standards with s:to_filename (should remain unchanged
    " for existing filenames, and will properly modify new files)
    let fname = call(g:wiki_map_text_to_file, [fname])

    " couple head back to (processed) filename
    let fixedpath = head.'/'.fname

    " get relative path from current file (using fixed path to ensure we have proper
    " filenames for realpath; it acts unexpectedly with spaces in filenames)
    let relpath = util#rel_path_from_file(fixedpath)

    " undo file naming transformation to get display name
    let dname = call(g:wiki_map_file_to_link, [fname])

    " return final concatenation
    " TODO: add g:wiki_link_conceal conditional option here, one packs in the conceal link
    " syntax based on the user's set mappings
    
    "return '['.dname.']('.relpath.')'
    let linktext = '[['.dname.']]'

    " compute whether or not to push link to next line
    if getcurpos()[2]+strlen(linktext) > &tw
        let spacing = repeat(' ', &tw - getcurpos()[2])
        let linktext = spacing.linktext
    endif

    return linktext
endfunction

" Function to specificly handle FZF completed links in the mappings below
function! util#handle_completed_link(lines)
    " return to insert mode
    call feedkeys('A')

    " handle (presumably) single FZF selection
    let path = join(a:lines)

    " create file?

    " get link string for path (assumed relative to wiki root)
    return util#wrap_link(path)
endfunction

