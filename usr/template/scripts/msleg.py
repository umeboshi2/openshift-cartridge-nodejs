import os
import subprocess
import random
import time
import cPickle as Pickle
import json

import mechanize
from bs4 import BeautifulSoup

HOST_PREFIX = 'http://billstatus.ls.state.ms.us'
PREFIX = HOST_PREFIX

local_prefix = 'assets/msleg'

class BaseCollector(object):
    def __init__(self):
        self.browser = mechanize.Browser()
        self.url = None
        self.response = None
        self.pageinfo = None
        self.content = ''
        self.soup = None
        self.url_prefix = HOST_PREFIX

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
        
class MeasuresCollector(CacheCollector):
    all_index_url = HOST_PREFIX + '/2017/pdf/all_measures/allmsrs.xml'
    def __init__(self):
        super(MeasuresCollector, self).__init__()
        self.set_url(self.all_index_url)
        self.msrgroups = []
        

    def parse_msrgroup(self, msrgroup):
        group = {}
        for ch in msrgroup.children:
            if hasattr(ch, 'name'):
                if ch.name is None:
                    continue
                group[ch.name] = ch.text
        return group

    def get_action_links(self):
        for group in self.msrgroups:
            dirname = os.path.dirname(self.all_index_url)
            link = group['actionlink']
            while link.startswith('../'):
                dirname = os.path.dirname(dirname)
                link = link[3:]
            url = os.path.join(dirname, link)
            print "url", url
            self.set_url(url)
            self.retrieve_content()
            
    def parse_all_measures(self):
        self.set_url(self.all_index_url)
        self.msrgroups = []
        self.retrieve_page()
        for msrgroup in self.soup.findAll('msrgroup'):
            parsed = self.parse_msrgroup(msrgroup)
            self.msrgroups.append(parsed)
            
class MembersCollector(CacheCollector):
    house_index_url = 'http://billstatus.ls.state.ms.us/members/hr_membs.xml'
    senate_index_url = 'http://billstatus.ls.state.ms.us/members/ss_membs.xml'
    def __init__(self):
        super(MembersCollector, self).__init__()

    def _retrieve_mblock(self, mblock, brange, prefix):
        for i in range(1, brange + 1):
            tag = 'm%d_link' % i
            link = getattr(mblock, tag)
            url = os.path.join(prefix, link.text)
            self.set_url(url)
            self.retrieve_page()
            # get images too
            img = self.soup.find('img_name')
            if img.text:
                url = os.path.join(os.path.dirname(self.url), img.text)
                self.set_url(url)
                self.retrieve_content()
        
    def _parse_mblock(self, mblock, brange):
        suffixes = ['name', 'link', 'bgc']
        parsed = []
        for i in range(1, brange + 1):
            data = {}
            for sfx in suffixes:
                tag = 'm%s_%s' % (i, sfx)
                data[sfx] = getattr(mblock, tag).text
            data['id'] = os.path.basename(data['link'])[:-4]
            parsed.append(data)
        return parsed
    
    def get_senate_members(self):
        self.set_url(self.senate_index_url)
        members_prefix = os.path.dirname(self.url)
        self.retrieve_page()
        for mblock in self.soup.findAll('member'):
            self._retrieve_mblock(mblock, 4, members_prefix)
            
    def parse_senate_members(self):
        self.set_url(self.senate_index_url)
        self.retrieve_page()
        parsed = []
        for mblock in self.soup.findAll('member'):
            parsed += self._parse_mblock(mblock, 4)
        return parsed
    
    def get_house_members(self):
        self.set_url(self.house_index_url)
        members_prefix = os.path.dirname(self.url)
        self.retrieve_page()
        for mblock in self.soup.findAll('member'):
            self._retrieve_mblock(mblock, 5, members_prefix)

    def parse_house_members(self):
        self.set_url(self.house_index_url)
        self.retrieve_page()
        members_prefix = os.path.dirname(self.url)
        parsed = []
        for mblock in self.soup.findAll('member'):
            parsed += self._parse_mblock(mblock, 5)
        #return parsed
        hdata = {}
        for prsd in parsed:
            hdata[prsd['id']] = prsd
            url = os.path.join(members_prefix, prsd['link'])
            self.set_url(url)
            self.retrieve_page()
            print self.soup
            time.sleep(2)
    
class MainCollector(CacheCollector):
    dbname = 'assets/msleg/db.pickle'
    dbjson = 'assets/msleg/db.json'
    def __init__(self):
        super(MainCollector, self).__init__()
        self.members = MembersCollector()
        self.measures = MeasuresCollector()
        self.set_database()

    def set_database(self):
        if os.path.isfile(self.dbname):
            self.T = Pickle.load(file(self.dbname))
        else:
            self.T = {}

    def save_database(self):
        Pickle.dump(self.T, file(self.dbname, 'w'))
        
    def save_json(self):
        json.dump(self.T, file(self.dbjson, 'w'))

    def refresh_database(self):
        raise RuntimeError, "no refresh db"

if __name__ == "__main__":
    allmsrs = HOST_PREFIX + '/2017/pdf/all_measures/allmsrs.xml'
    hr_membs = HOST_PREFIX + '/members/hr_membs.xml'
    m = MainCollector()
    #m.set_url(allmsrs)
    #m.retrieve_page()
    #m.set_url(hr_membs)
    #m.retrieve_page()
    #m.members.get_house_members()
    #m.members.get_senate_members()
    #m.measures.parse_all_measures()
    print "parse house"
    hp = m.members.parse_house_members()
    print "parse senate"
    sp = m.members.parse_senate_members()
    hid = [s['id'] for s in hp]
    sid = [s['id'] for s in sp]
