Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

qs = require 'qs'
xml = require 'xml2js-parseonly/src/xml2js'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'msleg'

parse_xhr_xml = (xhr, cb) ->
  Parser = new xml.Parser
    explicitArray: false
    normalizeTags: true
    async: false
  Parser.parseString xhr.responseText, (err, json) ->
    cb json

get_xml = (url, cb) ->
  xhr = Backbone.ajax
    type: 'GET'
    dataType: 'text'
    url: url
  xhr.done ->
    parse_xhr_xml xhr, cb
  

AppChannel.reply 'get-xml-url', (url, cb) ->
  get_xml url, cb
  
      
module.exports =
  get_xml: get_xml
  parse_xhr_xml: parse_xhr_xml
  
