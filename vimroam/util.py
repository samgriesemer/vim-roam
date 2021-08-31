#import vim
import os
import shutil
import sys
import re
import logging

from tqdm import tqdm

def copy_file(ipath, opath):
    shutil.copy2(ipath, opath)

def directory_tree(path):
    '''Return list of paths for all non-hidden files _inside_ of `path`. '''
    paths = []
    for (dirpath, dirnames, filenames) in os.walk(path):
        paths += [os.path.relpath(os.path.join(dirpath, file), path) \
                  for file in filenames if not \
                  any([dir.startswith('.') for dir in os.path.join(dirpath,file).split('/')])]
    return paths

def check_dir(path):
    '''Check if `path` exists, creating the necessary directories if not'''
    outdir = os.path.dirname(path)
    if not os.path.exists(outdir):
        os.makedirs(outdir)

def fname_to_title(fname):
    return fname.replace('_', ' ')

def title_to_fname(title):
    title = re.sub(r' *\n *', ' ', title)
    return title.replace(' ', '_')

def title_to_link(match, path=''):
    '''Return Markdown-style link from file title'''
    title = match.group(1)
    return '['+title+']('+path+title_to_fname(title)+')'


def get_var(name, default=None, vars_obj=None):
    """
    Params:
        default - default value, returned when variable is not found
        vars - used vars object, defaults to vim.vars
    """

    vars_obj = vars_obj or vim.vars
    value = vars_obj.get(name)

    if value is None:
        return default
    else:
        return decode_bytes(value)

#def show_in_split(lines, size=None, position="belowright", vertical=False,
#                  name="taskwiki", replace_opened=True,
#                  activate_cursorline=False):
#
#    # If there is no output, bail
#    if not lines:
#        print("No output.", file=sys.stderr)
#        return
#
#    # Sanitaze the output
#    lines = [l.rstrip() for l in lines]
#
#    # If the multiple buffers with this name are not desired
#    # cloase all the old ones in this tabpage
#    if replace_opened:
#        for buf in get_valid_tabpage_buffers(vim.current.tabpage):
#            shortname = buffer_shortname(buf)
#            if shortname.startswith(name):
#                vim.command('bwipe {0}'.format(shortname))
#
#    # Generate a random suffix for the buffer name
#    # This is needed since AnsiEsc saves the buffer name inside
#    # s: scoped variables. Also lowers the probability of clash with
#    # a real file.
#    random_suffix = random.randint(1,100000)
#    name = '{0}.{1}'.format(name, random_suffix)
#
#    # Compute the size of the split
#    if size is None:
#        if vertical:
#            # Maximum number of columns used + small offset
#            # Strip the color codes, since they do not show up in the split
#            size = max([len(strip_ansi_escape_sequence(l)) for l in lines]) + 1
#
#            # If absolute maximum width was set, do not exceed it
#            if get_var('taskwiki_split_max_width'):
#                size = min(size, get_var('taskwiki_split_max_width'))
#
#        else:
#            # Number of lines
#            size = len(lines)
#
#            # If absolute maximum height was set, do not exceed it
#            if get_var('taskwiki_split_max_height'):
#                size = min(size, get_var('taskwiki_split_max_height'))
#
#    # Set cursorline in the window
#    cursorline_activated_in_window = None
#
#    if activate_cursorline and not vim.current.window.options['cursorline']:
#        vim.current.window.options['cursorline'] = True
#        cursorline_activated_in_window = get_current_window()
#
#    # Call 'vsplit' for vertical, otherwise 'split'
#    vertical_prefix = 'v' if vertical else ''
#
#    vim.command("{0} {1}{2}split".format(position, size, vertical_prefix))
#    vim.command("edit {0}".format(name))
#
#    # For some weird reason, edit does not work for some users, but
#    # enew + file <name> does. Use as fallback.
#    if get_buffer_shortname() != name:
#        vim.command("enew")
#        vim.command("file {0}".format(name))
#
#    # If we were still unable to open the buffer, bail out
#    if get_buffer_shortname() != name:
#        print("Unable to open a new buffer with name: {0}".format(name))
#        return
#
#    # We're good to go!
#    vim.command("setlocal noswapfile")
#    vim.command("setlocal modifiable")
#    vim.current.buffer.append(lines, 0)
#
#    vim.command("setlocal readonly")
#    vim.command("setlocal nomodifiable")
#    vim.command("setlocal buftype=nofile")
#    vim.command("setlocal nowrap")
#    vim.command("setlocal nonumber")
#
#    # Keep window size fixed despite resizing
#    vim.command("setlocal winfixheight")
#    vim.command("setlocal winfixwidth")
#
#    # Make the split easily closable
#    vim.command("nnoremap <silent> <buffer> q :bwipe<CR>")
#    vim.command("nnoremap <silent> <buffer> <enter> :bwipe<CR>")


class TqdmLoggingHandler(logging.Handler):
    def __init__(self, level=logging.NOTSET):
        super().__init__(level)

    def emit(self, record):
        try:
            msg = self.format(record)
            tqdm.write(msg)
            self.flush()
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            self.handleError(record)

