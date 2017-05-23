_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'mscode'

class SimpleMeetingView extends Backbone.Marionette.View
  template: tc.renderable (model) ->
    name = "meeting"
    item_btn = ".btn.btn-default.btn-xs"
    tc.li ".list-group-item.#{name}-item", ->
      tc.span ->
        tc.a href:"#hubby/viewmeeting/#{model.id}", model.title
      #tc.div '.btn-group.pull-right', ->
      #  tc.button ".edit-item.#{item_btn}.btn-info.fa.fa-edit", 'edit'
      #  tc.button ".delete-item.#{item_btn}.btn-danger.fa.fa-close", 'delete'

class ListMeetingsView extends Backbone.Marionette.CompositeView
  childView: SimpleMeetingView
  template: tc.renderable () ->
    tc.div '.listview-header', ->
      tc.text "Meetings"
    tc.hr()
    tc.ul "#meetings-container.list-group"


class TitleEntry extends Backbone.Marionette.View
  template: tc.renderable (model) ->
    tc.div '.model-type.list-group-item', ->
      title = "Title #{model.id} - #{model.title}"
      tc.a href:"#mscode/titles/#{model.id}", title

class TitleListCollection extends Backbone.Marionette.CollectionView
  childView: TitleEntry

class TitleList extends Backbone.Marionette.View
  regions:
    list: '.mscode-titles'
    header: '.listview-header'
  template: tc.renderable ->
    tc.div '.listview-header', ->
      tc.a href:"#mscode", "Titles"
    tc.div '.mscode-titles.list-group'

  onRender: ->
    view = new TitleListCollection
      collection: @collection
    @showChildView 'list', view
    
class ChapterEntry extends Backbone.Marionette.View
  template: tc.renderable (model) ->
    tc.div '.model-type.list-group-item', ->
      href = "#mscode/titles/#{model.tnum}/chapters/#{model.id}"
      tc.a href:href, "Chapter #{model.id} - #{model.title}"

class ChapterListCollection extends Backbone.Marionette.CollectionView
  childView: ChapterEntry
  
class ChapterList extends Backbone.Marionette.View
  regions:
    list: '.mscode-chapters'
    header: '.listview-header'
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.a href:"#mscode", "Title - #{model.tnum}"
    tc.div '.mscode-chapters.list-group'
  
  onRender: ->
    view = new ChapterListCollection
      collection: @collection
    @showChildView 'list', view
    
class SectionEntry extends Backbone.Marionette.View
  template: tc.renderable (model) ->
    m = model
    tc.div '.model-type.list-group-item', ->
      href = "#mscode/titles/#{m.tnum}/chapters/#{m.cnum}/sections/#{m.id}"
      tc.a href:href, "Section #{m.id} - #{m.title}"

class SectionListCollection extends Backbone.Marionette.CollectionView
  childView: SectionEntry
      
class SectionList extends Backbone.Marionette.View
  regions:
    list: '.mscode-sections'
    header: '.listview-header'
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      title = "Title - #{model.tnum}, Chapter - #{model.cnum}"
      tc.a href:"#mscode/titles/#{model.tnum}", title
    tc.div '.mscode-sections.list-group'
  
  onRender: ->
    view = new SectionListCollection
      collection: @collection
    @showChildView 'list', view
    
module.exports =
  TitleList: TitleList
  ChapterList: ChapterList
  SectionList: SectionList
  
