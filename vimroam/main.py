import vim
import sys
from time import sleep

from panja.cache   import Cache
from panja.graph   import ArticleGraph

BASE_DIR = vim.eval("s:plugin_path")
sys.path.insert(0, BASE_DIR)

from vimroam import bl
# can elect to only update backlink pages (based on modified times) when the user requests
# the backlink buffer i.e. not doing it automatically as they write to files in the wiki.
# Or you could do this, trying to always keep everything up to date at the earliest
# possible moment. Will probably stick to the former approach for now

# IMPLEMENTATION:

## starting with native Panja objects, will likely replace with tighter score Vim-roam
## objects later. Don't think it's worth trying to global these efforts despite the
## similarity between what I'll do here and with the site _beyond_ the caching system,
## which should be able to overlap fine.

## wiki.vim treats cahce as interface for getting items out of the underlying dict. That
## is, if I want a key out of the cached dict, I could call cache.get(key), instead of
## getting the raw dict first after loading the cache and then manually grabbing the key.
## Note also that the cache object only does anything when read or load is called when
## there is a noticeable change on disk (which makes sense). Otherwise in my case here
## calling load() should do nothing if we already have the current state loaded (i.e.
## start with mod_time of -1, load and change to current time. Then only reload when
## mod_time on disk is different from that stored; will always be different if not yet
## loaded).


# For now, dont need to refresh buffer on file write since changes to the file dont change
# its backlinks. However, if at some point in the future arbitrary file's backlinks can be
# loaded regardless of the current file, then we should probably just reload the buffer
# content after what we already plan to do on write (i.e. update the current file in the
# graph)

# can we just write the graph to disk on garbage collection? like how can we wait until
# the last possible moment to write

# we dont handle the case of what happens when the blbuffer's buffer actually gets
# manually destroyed. Not this will be common at all, but the object will try to open a
# window with the buffer and set a non-existent buffer number, giving "invalid range" most
# likely

CACHE_PATH = vim.eval('expand(g:roam_cache_root)')

graph_cache = Cache(
    'graph',
    CACHE_PATH,
    lambda: ArticleGraph()
)

blbuffer = bl.BacklinkBuffer(graph_cache)

