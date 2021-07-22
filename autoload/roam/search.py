#!/env/bin/python

import sys
from os import path
import re
import glob

# also implement full file in one line

# could be a little smarter and also split by list item if
# we really cared to

wiki_root = '~/Documents/notes'
full_page = False
if len(sys.argv) > 1:
    wiki_root = sys.argv[1]
if len(sys.argv) > 2:
    if sys.argv[2] == '1':
        full_page = True

for fname in glob.glob(path.join(wiki_root, '**/*.md'), recursive=True):
    file_strs = []
    cur_str = []
    fn = fname.split('/')[-1]
    with open(fname, 'r') as f:
        for i, line in enumerate(f.readlines()):
            lstrip = line.strip()
        
            if not full_page:
                if lstrip == '':
                    if not cur_str: continue
                    file_strs.append(''.join(cur_str))
                    cur_str = []
                    continue

                if re.match('^(-|\d+\.) ', lstrip):
                    if cur_str: file_strs.append(''.join(cur_str))
                    cur_str = []

            if not cur_str: cur_str = [fn, ':', str(i+1), ':', '1', ':']
            cur_str.append(lstrip+' ')
    file_strs.append(''.join(cur_str))
    file_str = '\n'.join(file_strs)
    print(file_str)
