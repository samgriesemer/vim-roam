import re
from collections import defaultdict
from datetime import datetime
import subprocess as subp

import pypandoc as pp
import pandocfilters as pf
from colorama import Fore

from vimroam import util

# captures base link, anchors, display text; any combo of them
link_regex = re.compile('\[\[([^\]]*?)(#[^\]]*?)?(?:\|([^\]]*?))?\]\]')

class Note:
    def __init__(self, fullpath, name, verbose=True):
        self.fullpath = fullpath
        self.name = name

        self.link = name
        self.html = {}
        self.raw_content = ''
        self.raw_lines = []
        self.content = ''
        self.valid = True
        self.verbose = verbose
        self.ctime = datetime.now().timestamp()

        # lightweight parsing
        self.metadata = self.process_metadata()
        self.links = {}
        self.tree = {}
        self.linkdata = {}

    def process_metadata(self):
        with open(self.fullpath, 'r') as f:
            ft = f.read()
            self.raw_content = ft

            f.seek(0)
            self.raw_lines = f.readlines()

            metadata = {}
            mt = re.match('---\n(.*?)\n(---|\.\.\.)', ft, flags=re.DOTALL)

            if mt is None:
                self.content = ft
                self.valid = False

                if self.verbose:
                    print(Fore.RED + '[invalid metadata] ' + Fore.RESET + self.name)

                return metadata

            self.content = ft.replace(mt.group(0), '')

            # doesnt face issues if metadata components have colon and are only
            # one line, but when multiline colons can have unexpected effects
            #print(mt.group(1))
            for m in re.findall('.*:[^:]*$', mt.group(1), flags=re.MULTILINE):
                split = [m.split(':')[0], ':'.join(m.split(':')[1:])]
                attr, val = map(str.strip, split)
                metadata[attr.lower()] = val

            if 'tags' in metadata:
                metadata['tag_links'] = self.process_links(metadata['tags'])
            
            if 'series' in metadata:
                #print(metadata['series'])
                metadata['series_links'] = self.process_links(metadata['series'])
            #print(metadata)

        return metadata

    def context_tree(self):
        tree = {}
        current_header = {'c': ''}

        def comp(key, value, format, meta):
            if key == 'Header':
                title = []
                for v in value[2]:
                    for vc in v['c'][1:]:
                        outer = vc
                        if type(outer) == str:
                            title.append(outer)
                            continue
                        elif type(outer[0]) == str:
                            title.append(outer[0])
                            continue
                        elif 'c' in outer[0]:
                            title.append(outer[0]['c'])
                        else:
                            title.append(' ')
                current_header['c'] = ''.join([str(s) for s in title])

            if key == 'BulletList' or key == 'OrderedList':
                v = value if key == 'BulletList' else value[1]

                for item in v:
                    pos   = item[0]['c'][0][2][0][1].split('@')[-1].split('-')
                    start = pos[0]
                    end   = pos[-1]

                    sl, sc = map(int, start.split(':'))
                    el, ec = map(int, end.split(':'))

                    obj = {
                        'c': [],
                        'p': tree.get(sl),
                        'v': ''.join(self.raw_lines[(sl-1):(el-1)]),
                        'h': current_header['c']
                    }

                    if obj['p'] is not None:
                        obj['p']['c'].append(obj)

                    for i in range(sl, el):
                        tree[i] = obj

            if key == 'Para':
                start = value[0]['c'][0][2][0][1].split('@')[-1].split('-')[0]
                end   = value[-1]['c'][0][2][0][1].split('@')[-1].split('-')[-1]

                sl, sc = map(int, start.split(':'))
                el, ec = map(int, end.split(':'))

                obj = {
                    'c': [],
                    'p': None,
                    'v': ''.join(self.raw_lines[(sl-1):el]),
                    'h': current_header['c']
                }

                for i in range(sl, el+1):
                    if tree.get(i) is None:
                        tree[i] = obj

        #cm = pp.convert_file(self.fullpath, format='commonmark+sourcepos', to='json')
        cm = subp.check_output(["pandoc", "--from", "commonmark+sourcepos", "--to", "json", self.fullpath])
        pf.applyJSONFilters([comp], cm)

        return tree

    def process_linkdata(self):
        links = link_regex.finditer(self.raw_content)
        linkdata = defaultdict(list)

        for m in links:
            # positional processing
            start = m.start()
            line = self.raw_content.count('\n', 0, start) +1
            col = start - self.raw_content.rfind('\n', 0, start)
            #name = util.title_to_fname(m.group(1))
            name = m.group(1)

            text = '(will be removed)'
            header = ''
            context = self.tree.get(line, '')
            if context:
                if context.get('p'):
                    header = context['p']['h']
                    text = context['p']['v']
                else:
                    header = context['h']
                    text = context['v']
            else: continue
           
            linkdata[name].append({
                'ref':  self,
                'line': line,
                'col':  col,
                'context': text,
                'header': str(header)
            })

        return linkdata

    def process_links(self, string):
        links = link_regex.findall(string)
        lcounts = defaultdict(int)

        for link in links:
            lcounts[link[0]] += 1

        return lcounts

    def process_structure(self):
        self.links    = self.process_links(self.content)
        self.tree     = self.context_tree()
        self.linkdata = self.process_linkdata()

