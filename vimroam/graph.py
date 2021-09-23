import json
from collections import defaultdict

class Graph:
    def __init__(self):
        self.article_map = {}

        # adjacency list indexes
        self.fgraph = defaultdict(dict)
        self.bgraph = defaultdict(dict)

        # global metadata indexes
        self.tag_map = defaultdict(set)
        self.series_map = defaultdict(set)
        self.bl_map = defaultdict(lambda: defaultdict(list))
        self.bl_head = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))

    def get_article(self, name):
        return self.article_map.get(name) 

    def get_article_list(self):
        return list(self.article_map.values())

    def get_article_list_as_json(self):
        return json.dumps(self.fgraph)

    def get_adj_list(self):
        return self.fgraph

    def get_tag_list(self, name):
        return list(self.tag_map.get(name, []))

    def get_series_list(self, name):
        return list(self.series_map.get(name, []))

    def get_series_text_list(self, name):
        slist = []
        for series in self.get_series_list(name):
            stext = self.get_article(series).metadata.get('series','')
            slist.append(stext)
        return slist

    def get_series_obj_list(self, name):
        return [self.article_map[s] for s in self.get_series_list(name)]

    def get_backlinks(self, name):
        return self.bl_map.get(name, {})

    def get_headlinks(self, name):
        return self.bl_head.get(name, {})

    def get_edge_list(self):
        nodes = []
        edges = []
        for aname, links in self.fgraph.items():
            article = self.article_map[aname]
            data = {
                'name': article.name,
                'link': article.link,
                'valid': article.valid,
                'num_links': sum(self.bgraph[aname].values())
            }
            data.update(article.metadata)
            nodes.append(data)

            for target, val in links.items():
                if target in self.article_map:
                    edges.append({
                        'source': aname,
                        'target': target,
                        'value': val
                    })

        return {'nodes': nodes, 'links': edges}

    def get_subgraph(self, name):
        article = self.article_map[name]
        data = {
            'name': article.name,
            'link': article.link,
            'valid': article.valid,
            'num_links': sum(self.bgraph[name].values())
        }
        data.update(article.metadata)
        node_track = set([article.name])
        nodes = [data]
        edges = []

        for tname, count in [*self.fgraph[name].items(), *self.bgraph[name].items()]:
            if tname not in self.article_map: continue
            target = self.article_map[tname]
            if target.name not in node_track:
                data = {
                    'name': target.name,
                    'link': target.link,
                    'valid': target.valid,
                    'num_links': sum(self.bgraph[target.name].values())
                }
                data.update(target.metadata)
                nodes.append(data)
                node_track.add(target.name)
            
        for tname, count in self.fgraph[name].items():
            if tname not in self.article_map: continue
            edges.append({
                'source': name,
                'target': tname,
                'value': count
            })

        for tname, count in self.bgraph[name].items():
            if tname not in self.article_map: continue
            edges.append({
                'source': tname,
                'target': name,
                'value': count
            })

        return {'nodes': nodes, 'links': edges}

    def add_article(self, article):
        from timeit import default_timer as timer
        # reset indexes if article previously processed
        s = timer()
        if article.name in self.article_map:
            cur_article = self.article_map[article.name]
            self.fgraph[article.name] = {}

            for name in cur_article.links:
                self.bgraph[name].pop(article.name, None)
                self.bl_map[name].pop(article.name, None)

            for tag in cur_article.metadata.get('tag_links', []):
                self.tag_map[tag].remove(article.name)

            for ref in cur_article.metadata.get('series_links', []):
                self.series_map[ref].remove(article.name)
        
        self.article_map[article.name] = article
        p = timer()
        self.process_links(article)
        l = timer()
        self.process_tags(article)
        t = timer()
        self.process_series(article)
        r = timer()
        self.process_backlinks(article)
        b = timer()

        print('processing: {}s'.format(p-s))
        print('links: {}s'.format(l-p))
        print('tags: {}s'.format(t-l))
        print('series: {}s'.format(r-t))
        print('backlinks: {}s'.format(b-r))


    def process_links(self, article):
        for link, count in article.links.items():
            self.fgraph[article.name][link] = count
            self.bgraph[link][article.name] = count
            
    def process_tags(self, article):
        if 'tag_links' in article.metadata:
            for tag in article.metadata['tag_links']:
                self.tag_map[tag].add(article.name)

    def process_series(self, article):
        if 'series_links' in article.metadata:
            self.series_map[article.name].add(article.name)
            for ref in article.metadata['series_links']:
                self.series_map[ref].add(article.name)

    def process_backlinks(self, article):
        for name, data in article.linkdata.items():
            self.bl_map[name][article.name] += data

            for link in data:
                self.bl_head[name][link['header']][article.name] += [link]

