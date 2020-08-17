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

