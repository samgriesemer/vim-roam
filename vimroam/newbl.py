import vim
import sys
from pathlib import Path
from time import sleep
from random import randint

WIKI_ROOT = vim.eval('expand(g:wiki_root)')

class BacklinkBuffer():
    def __init__(self, graph_cache, verbose=False):
        self.bufnr = int(vim.eval('bufnr("backlink-buffer.{}", 1)'.format(randint(1,100000))))
        self.nbuf = vim.buffers[self.bufnr]
        
        self.graph_cache = graph_cache
        self.verbose = verbose

    def open(self, name=None):
        win_list = vim.eval('win_findbuf({})'.format(self.bufnr))
        if not win_list:
            vim.command('rightb vert {}sb'.format(self.bufnr))
            vim.command('setlocal noswapfile')
            vim.command('setlocal modifiable')
            #vim.command('filetype plugin off')
            vim.command('setlocal buftype=nofile')

            # a thought to change up ft
            #vim.command('setlocal filetype=backlink')
            vim.command('setlocal filetype=markdown')

        vim.command('asyncrun#run("", {}, "python3 -m vimroam.main '+WIKI_ROOT+'"')

        self.nbuf[:] = None
        if name is None:
            self.nbuf.append('Open a file to get started', 0)
        elif name not in self.graph.article_map:
            self.nbuf.append('File not in graph, is it valid?', 0)
        else:
            self.populate_buffer(name)
            # close folds?
            vim.command('normal! zM')

    def close(self):
        win_list = vim.eval('win_findbuf({})'.format(self.bufnr))

        if win_list:
            win_num = vim.eval('win_id2win({})'.format(win_list[0]))
            vim.command('{}wincmd c'.format(win_num))

    def populate_buffer(self, name):
        backlinks = self.graph.get_backlinks(name)
        #headlinks = graph.get_headlinks(name)
        #structlinks = {}

        #headers = ['Log', 'Thoughts']
        #for header in headers:
            #if header not in headlinks: continue
            #structlinks[header] = dict(sorted(headlinks[header].items(),
                                       #key=lambda x: x[1][0]['ref'].metadata['created']))
    #
        for srclist in backlinks.values():
            title = srclist[0]['ref'].metadata['title']

            self.nbuf.append('# {t} ([[{t}]])'.format(t=title))
            for link in srclist:
                self.nbuf.append(link['context'].split('\n'))
                vim.command('redraw')
                    #self.nbuf.append(line)
                    ##link.line
                    ##link.col
