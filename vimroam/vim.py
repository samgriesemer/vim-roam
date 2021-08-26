from vimroam.bl import BacklinkBuffer

roam_graph_cache = RoamCache(
    'graph',
    cachepath,
    lambda: RoamGraph()
)

blbuffer = BacklinkBuffer(roam_graph_cache)
