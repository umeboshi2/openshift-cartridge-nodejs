Backbone = require 'backbone'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'mscode'

apiroot = '/api/dev/mscode'

class MSTitle extends Backbone.Model
  url: ->
    "#{apiroot}/dbtitles/#{@id}"

class MSTitleCollection extends Backbone.Collection
  url: "#{apiroot}/dbtitles"

make_chapter_collection = (tnum) ->
  class ChapterCollection extends Backbone.Collection
    url: "#{apiroot}/dbchapters/#{tnum}"
  ChapterCollection

make_section_collection = (tnum, cnum) ->
  class SectionCollection extends Backbone.Collection
    url: "#{apiroot}/dbsections/#{tnum}/#{cnum}"
  SectionCollection
  
AppChannel.reply 'title-collection', ->
  return new MSTitleCollection

AppChannel.reply 'chapter-collection', (tnum) ->
  Collection = make_chapter_collection tnum
  return new Collection

AppChannel.reply 'section-collection', (tnum, cnum) ->
  Collection = make_section_collection tnum, cnum
  return new Collection
  


  
module.exports =
  MSTitle: MSTitle
  
