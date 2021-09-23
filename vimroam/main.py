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

import sys
import os 
import argparse
from pathlib import Path
import logging
from tqdm import tqdm

from vimroam.cache import Cache as RoamCache
from vimroam.graph import Graph as RoamGraph
from vimroam.note  import Note  as RoamNote
from vimroam import util as rutil

# For now, can: have BLBuffer object that was be pure vimscript; run pure python calls to
# local package. for buffer just write the output from the script

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = rutil.TqdmLoggingHandler()
logger.addHandler(handler)

def update_graph_node(note, graph, wiki_root):
    # single file update, hook to write event
    path = Path(wiki_root, note)
    #name = path.stem
    # or
    name = str(Path(note).with_suffix(''))
    if path.suffix != '.md': return False

    if name in graph.article_map:
        if path.stat().st_mtime < graph.article_map[name].ctime:
            return False

    note = RoamNote(str(path), name, verbose=False)
    #if not note.valid: return False

    note.process_structure()
    graph.add_article(note)
    return True

def update_graph(graph, wiki_root, verbose=True):
    write = False
    if verbose:
        logger.info('Scanning note graph...')
    for note in tqdm(rutil.directory_tree(wiki_root)):
        if update_graph_node(note, graph, wiki_root):
            write = True
            if verbose:
                logger.info('-> Updating {}'.format(note))
    return write

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('wiki', help='wiki root path')
    parser.add_argument('--cache', default='~/.cache/vim-roam/', help='cache root path')
    parser.add_argument('--name', help='note name data to retrieve')
    parser.add_argument('-v', '--verbose', help='verbosity of logging', action='store_true')
    parser.add_argument('-w', '--write', help='write content output to file', action='store_true')
    parser.add_argument('--no-update', help='no update flag', action='store_true')
    args = parser.parse_args()

    notepath  = os.path.expanduser(args.wiki)
    cachepath = os.path.expanduser(args.cache)

    if args.verbose:
        print('Wiki root: {}'.format(notepath))
        print('Cache root: {}'.format(cachepath))

    roam_graph_cache = RoamCache(
        'graph',
        cachepath,
        lambda: RoamGraph()
    )

    if args.verbose:
        logger.info('Loading note graph...')
    roam_graph = roam_graph_cache.load()

    if not args.no_update:
        if update_graph(roam_graph, notepath, args.verbose):
            if args.verbose:
                logger.info('Writing note graph...')
            roam_graph_cache.write(roam_graph)

    content = ''
    if args.name:
        tag_list = roam_graph.get_tag_list(args.name)
        if tag_list:
            hstr = '== Tags for {} =='.format(args.name)
            if args.write: content += hstr+'\n'
            else: print(hstr)

        for tag in tag_list:
            tstr = '+ [[{}]]'.format(tag)
            if args.write: content += tstr+'\n'
            else: print(tstr)

        if args.write: content += '\n'
        else: print()

        backlinks = roam_graph.get_backlinks(args.name)
        if backlinks:
            hstr = '== Backlinks for {} =='.format(args.name)
            if args.write: content += hstr+'\n'
            else: print(hstr)

        for srclist in backlinks.values():
            ref = srclist[0]['ref']
            title = ref.metadata.get('title')
            if title is None:
                title = ref.name

            tstr = '# {t} ([[{n}]])'.format(t=title, n=ref.name)
            if args.write: content += tstr+'\n'
            else: print(tstr)

            for link in srclist:
                cstr = link['context'].strip()+'\n'
                if args.write: content += cstr+'\n'
                else: print(cstr)



    if args.write:
        with open(str(Path(cachepath, 'backlink.buffer')), 'w') as f:
            f.write(content)


