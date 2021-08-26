import vim

from vimroam.bl import BacklinkBuffer

CACHE_PATH = vim.eval('expand(g:roam_cache_root)')

roam_graph_cache = RoamCache(
    'graph',
    CACHE_PATH,
    lambda: RoamGraph()
)

blbuffer = BacklinkBuffer(roam_graph_cache)
