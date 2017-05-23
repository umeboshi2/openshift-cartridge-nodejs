Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
PageableCollection = require 'backbone.paginator'

{ parse_xhr_xml } = require './getxml'
xml = require 'xml2js-parseonly/src/xml2js'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'msleg'

cfg_env = 'production'
if __DEV__
  cfg_env = 'development'
config = require('./config')[cfg_env]

class XMLParseModel extends Backbone.Model
  fetch: (options) =>
    p = super options
    p.always = (xhr) ->
      Parser = new xml.Parser
        explicitArray: false
        normalizeTags: true
        async: false
      Parser.parseString xhr.responseText, (err, json) ->
        p.json = json
    return p
    
class RssModel extends XMLParseModel

class TestRssModel extends RssModel
  url: '/assets/rss2.xml'
  

class SomethingModel extends Backbone.Model

class SomethingCollection extends Backbone.Collection
  model: SomethingModel

      
module.exports =
  SomethingModel: SomethingModel
  TestRssModel: TestRssModel
