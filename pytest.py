import sys
from pathlib import Path
from random import randint

from panja.article import Article
from panja import utils

from panja.cache import Cache as RoamCache
from panja.graph import ArticleGraph


WIKI_ROOT = '/home/smgr/Documents/notes'
ROAM_CACHE_PATH = '/home/smgr/.cache/vim-roam/'

def update_graph_node(note):
    # single file update, hook to write event
    path = Path(WIKI_ROOT, note)
    name = path.stem

    if path.suffix != '.md': return False

    if name in graph.article_map:
        if path.stat().st_mtime < graph.article_map[name].ctime:
            return False

    article = Article(str(path), name, verbose=False)
    if not article.valid: return False

    article.process_structure()
    graph.add_article(article)
    return True

def update_graph():
    # full graph update, likely hook to initialization or manual command
    print('Scanning note graph', file=sys.stdout)

    # might want to consider cached files that _dont_ show up when this method is
    # called? i.e. they've been deleted but are still in the cache, nothing currently
    # updates these

    for note in utils.directory_tree(WIKI_ROOT):
        if update_graph_node(note):
            print('-> Updating {}'.format(note), file=sys.stdout)
            
    #self.graph_cache.write(self.graph)


roam_graph_cache = RoamCache(
    'graph',
    ROAM_CACHE_PATH,
    lambda: ArticleGraph()
)

print('Loading cached graph...', file=sys.stdout)
graph = roam_graph_cache.load()

print('Updating graph...', file=sys.stdout)
update_graph()


