import os
import subprocess
import random
import time
import cPickle as Pickle
import json

import mechanize
from bs4 import BeautifulSoup

HOST_PREFIX = 'http://law.justia.com'
PREFIX = '%s/codes/mississippi/2015' % HOST_PREFIX

local_prefix = 'assets/mississippi/2015'

class BaseCollector(object):
    def __init__(self):
        self.browser = mechanize.Browser()
        self.url = None
        self.response = None
        self.pageinfo = None
        self.content = ''
        self.soup = None
        self.url_prefix = 'http://mclawvideo.org/courtvideo/'

    def parse_page(self):
        self.soup = BeautifulSoup(self.content, 'lxml')
        
    def retrieve_page(self, url=None):
        if url is None:
            url = self.url
        else:
            self.set_url(url)
        if url is None:
            raise RuntimeError("No url set.")
        self.response = self.browser.open(self.url)
        self.info = self.response.info()
        self.content = self.response.read()
        self.parse_page()
        

    def set_url(self, url):
        self.url = url
        self.response = None
        self.pageinfo = None
        self.content = ''
        self.soup = None

    def collect(self):
        pass


class CacheCollector(BaseCollector):
    def local_filename(self):
        suffix = self.url.split(PREFIX)[1]
        while suffix.startswith('/'):
            suffix = suffix[1:]
        return os.path.join(local_prefix, suffix)
        
    def is_cached(self):
        return os.path.exists(self.local_filename())
        
    def save_content(self):
        filename = self.local_filename()
        dirname = os.path.dirname(filename)
        if not os.path.isdir(dirname):
            print "creating", dirname
            os.makedirs(dirname)
        print "Saving", filename
        with file(filename, 'w') as outfile:
            outfile.write(self.content)

    def get_local_content(self):
        filename = self.local_filename()
        #print "Getting", filename
        self.content = file(filename).read()
        
    def retrieve_content(self, url=None):
        if url is None:
            url = self.url
        else:
            self.set_url(url)
        if url is None:
            raise RuntimeError("No url set.")
        if self.is_cached():
            self.get_local_content()
        else:
            self.get_from_web()
            
    def retrieve_page(self, url=None):
        self.retrieve_content(url=url)
        self.parse_page()
            

    def get_from_web(self):
        print "Getting from web:", self.url
        self.response = self.browser.open(self.url)
        self.info = self.response.info()
        self.content = self.response.read()
        self.save_content()
        

class TitleCollector(CacheCollector):
    def __init__(self):
        super(TitleCollector, self).__init__()
        self.url = 'http://law.justia.com/codes/mississippi/2015/index.html'

    def get_titles(self):
        prefix = '/codes/mississippi/2015/title'
        anchors = self.soup.findAll('a')
        titles = dict()
        for anchor in anchors:
            if anchor.has_attr('href') and anchor['href'].startswith(prefix):
                url = anchor['href']
                utitle = os.path.basename(os.path.dirname(url))
                title = anchor.text.split(' - ')[1]
                number = int(utitle.split('-')[1])
                data = dict(url=url, title=title, number=number)
                if number in titles:
                    raise RuntimeError, "duplicate title %s" % url
                titles[number] = data
        return titles
    
        


class ChapterCollector(CacheCollector):
    def __init__(self):
        super(ChapterCollector, self).__init__()
        self.title_num = None

    def set_title_data(self, data):
        self.titles = data
        
    def set_title(self, number):
        self.title_num = number
        t = self.titles[number]
        turl = HOST_PREFIX + t['url']
        self.set_url(turl)


    def get_chapter_lists(self):
        for number in self.titles:
            self.set_title(number)
            self.retrieve_page()
            #time.sleep(random.random() * 2)
            

    def get_chapters(self, number):
        self.set_title(number)
        self.retrieve_page()
        anchors = self.soup.findAll('a')
        prefix = '/codes/mississippi/2015/title'
        chapters = dict()
        for anchor in anchors:
            if anchor.has_attr('href') and anchor['href'].startswith(prefix):
                url = anchor['href']
                #print "url", url
                utitle = os.path.basename(os.path.dirname(url))
                title = anchor.text.split(' - ')[1]
                number = utitle.split('-')[1]
                data = dict(url=url, title=title, number=number)
                if number in chapters:
                    raise RuntimeError, "duplicate title %s" % url
                chapters[number] = data
        return chapters

    def get_csections(self):
        anchors = self.soup.findAll('a')
        prefix = '/codes/mississippi/2015/title'
        csections = dict()
        count = 0
        for anchor in anchors:
            if anchor.has_attr('href') and anchor['href'].startswith(prefix):
                count += 1
                url = anchor['href']
                #print "url", url
                utitle = os.path.basename(os.path.dirname(url))
                #title = anchor.text.split(' - ')[1]
                title = anchor.text
                count = count
                data = dict(url=url, title=title, csid=count)
                if count in csections:
                    raise RuntimeError, "duplicate title %s" % url
                csections[count] = data
        return csections

class MainCollector(object):
    dbname = 'assets/mississippi/db.pickle'
    dbjson = 'assets/mississippi/db.json'
    def __init__(self):
        self.titles = TitleCollector()
        self.titles.retrieve_page()
        self.chapters = ChapterCollector()
        self.set_database()
        

    def store_chapter(self, number):
        chapters = self.chapters.get_chapters(number)
        self.T[number]['chapters'] = chapters
        self.save_database()
        
    def store_chapters(self):
        for t in self.T:
            print "storing title", t, self.T[t]['title']
            self.store_chapter(t)
            
    def set_database(self):
        if os.path.isfile(self.dbname):
            self.T = Pickle.load(file(self.dbname))
        else:
            self.T = self.titles.get_titles()
        self.chapters.set_title_data(self.T)
        

    def save_database(self):
        Pickle.dump(self.T, file(self.dbname, 'w'))
        
    def save_json(self):
        json.dump(self.T, file(self.dbjson, 'w'))

    def refresh_database(self):
        self.T = self.titles.get_titles()
        self.chapters.set_title_data(self.T)
        self.save_database()
        # FIXME name this better
        # get chapter lists from titles
        self.store_chapters()
        self.save_database()
        # FIXME name this better
        # get section and article links from
        # chapter lists
        self.parse_chapters()
        self.save_database()
        # FIXME name this better
        # split chapter sections
        # into different groups
        self.get_odd_sections()
        # parse "subchapters"
        self.parse_subchapters()
        self.save_database()
        
    def get_chapter_index(self):
        tk = self.T.keys()
        random.shuffle(tk)
        tnum = tk[0]
        ch = self.T[tnum]['chapters']
        chk = ch.keys()
        random.shuffle(chk)
        return tnum, chk[0]
    
    def get_chapter_indexes(self):
        while True:
            tnum, cnum = self.get_chapter_index()
            ch = self.T[tnum]['chapters']
            url = HOST_PREFIX + ch[cnum]['url']
            self.chapters.set_url(url)
            if not self.chapters.is_cached():
                print "Retrieving", url
                self.chapters.retrieve_page()
        
    def parse_chapters(self):
        for tnum in self.T:
            ch = self.T[tnum]['chapters']
            for cnum in ch:
                print "parse title %s chapter %s: %s" % (tnum, cnum, ch[cnum]['title'])
                url = HOST_PREFIX + ch[cnum]['url']
                self.chapters.set_url(url)
                self.chapters.retrieve_page()
                csections = self.chapters.get_csections()
                ch[cnum]['csections'] = csections
            self.save_database()

    def _sleep(self):
        time.sleep(random.random())

    def retrieve_parsed_anchor(self, parsed):
        url = HOST_PREFIX + parsed['url']
        #print "URL", url
        self.chapters.set_url(url)
        self.chapters.retrieve_page()

    def get_parsed_anchor(self, parsed):
        url = HOST_PREFIX + parsed['url']
        #print "URL", url
        self.chapters.set_url(url)
        self.chapters.retrieve_content()
        
    def parse_subchapters(self):
        for tnum in self.T:
            ch = self.T[tnum]['chapters']
            for cnum in ch:
                cdata = ch[cnum]
                csections = cdata['csections']
                articles = cdata['articles']
                named = cdata['named']
                for a in articles:
                    article = articles[a]
                    self.retrieve_parsed_anchor(article)
                    url = article['url']
                    dirname = os.path.dirname(url)
                    basedir = os.path.basename(dirname)
                    anum = basedir.split('-')[1]
                    atitle = article['title'].split(' - ')[1]
                    article['anum'] = anum
                    asections = self.chapters.get_csections()
                    print tnum, cnum, basedir, atitle
                    article.update(dict(anum=anum,
                                        atitle=atitle, asections=asections))
                for n in named:
                    nd = named[n]
                    self.retrieve_parsed_anchor(nd)
                    url = nd['url']
                    dirname = os.path.dirname(url)
                    basedir = os.path.basename(dirname)
                    nsections = self.chapters.get_csections()
                    print tnum, cnum, basedir
                    nd['nsections'] = nsections
                    
        print "Finish parse_subchapters"
        self.save_database()
            
                    
                
    def get_odd_sections(self):
        for tnum in self.T:
            ch = self.T[tnum]['chapters']
            for cnum in ch:
                csections = ch[cnum]['csections']
                sections = {}
                articles = {}
                named = {}
                for csnum in csections:
                    d = csections[csnum]
                    url = HOST_PREFIX + d['url']
                    dirname = os.path.dirname(url)
                    basedir = os.path.basename(dirname)
                    if url.endswith('/index.html'):
                        if basedir.startswith('section-%s-%s-' % (tnum, cnum)):
                            sections[csnum] = d                            
                        elif basedir.startswith('article-'):
                            self.chapters.set_url(url)
                            if not self.chapters.is_cached():
                                self.chapters.retrieve_page()
                            articles[csnum] = d
                        else:
                            self.chapters.set_url(url)
                            if not self.chapters.is_cached():
                                self.chapters.retrieve_page()
                            named[csnum] = d
                ch[cnum]['sections'] = sections
                ch[cnum]['articles'] = articles
                ch[cnum]['named'] = named
                print "finish", tnum, cnum
            #self.save_database()
            print "TITLE", tnum
        self.save_database()
            
    
        
    def retrieve_all_sections(self):
        for tnum in self.T:
            ch = self.T[tnum]['chapters']
            for cnum in ch:
                cdata = ch[cnum]


    def retrieve_title_sections(self, tnum):
        for cnum in self.T[tnum]['chapters']:
            self.retrieve_sections(tnum, cnum)
            
    def retrieve_sections(self, tnum, cnum):
        #cnum = int(cnum)
        cnum = str(cnum)
        ch = self.T[tnum]['chapters']
        cdata = ch[cnum]
        sections = cdata['sections']
        for csid in sections:
            section = sections[csid]
            #print "SECTION", section
            self.get_parsed_anchor(section)
        for csid, article in cdata['articles'].items():
            for csid, asection in article['asections'].items():
                if asection['url'].endswith('/'):
                    continue
                print "ARTICLE", asection['title']
                self.get_parsed_anchor(asection)
        for csid, article in cdata['named'].items():
            for csid, nsection in article['nsections'].items():
                if nsection['url'].endswith('/'):
                    continue
                print "NAMED ARTICLE", nsection['title']
                self.get_parsed_anchor(nsection)
        
        
if __name__ == "__main__":
    if not os.path.isdir(local_prefix):
        print "Creating", local_prefix
        os.makedirs(local_prefix)
        
    #t = TitleCollector()
    #t.retrieve_page()
    #tl = t.get_titles()
    m = MainCollector()
    #trange = range(1,101,2)
    trange = range(73,101,2)
    for t in trange:
        m.retrieve_title_sections(t)
        
