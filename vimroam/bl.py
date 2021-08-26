import vim
import sys
from pathlib import Path
from time import sleep
from random import randint

from panja.article import Article
from panja import utils

WIKI_ROOT = vim.eval('expand(g:wiki_root)')

class BacklinkBuffer():
    def __init__(self, graph_cache, verbose=False):
        self.bufnr = int(vim.eval('bufnr("backlink-buffer.{}", 1)'.format(randint(1,100000))))
        self.nbuf = vim.buffers[self.bufnr]
        
        self.graph_cache = graph_cache
        self.graph = None
        self.verbose = verbose

    #def __del__(self):
        #print('Writing graph to cache', file=sys.stdout)
        #self.graph_cache.write(self.graph)

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
        vim.command('redraw')

        self.nbuf[:] = None
        if self.graph is None:
            self.nbuf.append('Loading cached graph...', 0)
            vim.command('redraw')

            self.graph = self.graph_cache.load()
            self.nbuf.append('Updating graph...', 1)
            vim.command('redraw')

            self.update_graph()

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

    def update_graph_node(self, note):
        # single file update, hook to write event
        path = Path(WIKI_ROOT, note)
        name = path.stem

        if path.suffix != '.md': return False

        if name in self.graph.article_map:
            if path.stat().st_mtime < self.graph.article_map[name].ctime:
                return False

        article = Article(str(path), name, verbose=False)
        if not article.valid: return False

        article.process_structure()
        self.graph.add_article(article)
        return True

    def update_graph(self):
        # full graph update, likely hook to initialization or manual command
        if self.verbose:
            print('Scanning note graph', file=sys.stdout)

        # might want to consider cached files that _dont_ show up when this method is
        # called? i.e. they've been deleted but are still in the cache, nothing currently
        # updates these

        for note in utils.directory_tree(WIKI_ROOT):
            if self.update_graph_node(note):
                self.nbuf.append('-> Updating {}'.format(note))
                vim.command('redraw')
                
            #print('-> Updating {}'.format(note), file=sys.stdout)

        # possibly delay this, pack into __del__ perhaps
        self.graph_cache.write(self.graph)

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
