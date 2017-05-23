Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
ms = require 'ms'

{ MainController } = require 'tbirds/controllers'
SlideDownRegion = require 'tbirds/regions/slidedown'

Views = require './views'


MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'mscode'

class AppletLayout extends Backbone.Marionette.View
  template: tc.renderable () ->
    tc.div '#main-content.col-sm-10.col-sm-offset-1'
  regions: ->
    region = new SlideDownRegion
      el: '#main-content'
    region.slide_speed = ms '.01s'
    content: region
  

class Controller extends MainController
  layoutClass: AppletLayout
  appRoutes:
    'mscode': 'list_models'

  show_titles: (layout, region) ->
    titles = AppChannel.request 'title-collection'
    response = titles.fetch()
    response.done () ->
      view = new Views.TitleList
        collection: titles
      layout.showChildView region, view
    response.fail ->
      MessageChannel.request 'danger', 'Failed to get titles'

  show_chapters: (layout, region, tnum) ->
    chapters = AppChannel.request 'chapter-collection', tnum
    response = chapters.fetch()
    response.done () ->
      model = new Backbone.Model
        tnum: tnum
      view = new Views.ChapterList
        collection: chapters
        model: model
      console.log 'chapters', chapters.url
      window.VV = view
      layout.showChildView region, view
    response.fail ->
      MessageChannel.request 'danger', 'Failed to get titles'
    
  show_sections: (layout, region, tnum, cnum) ->
    sections = AppChannel.request 'section-collection', tnum, cnum
    response = sections.fetch()
    response.done () ->
      model = new Backbone.Model
        tnum: tnum
        cnum: cnum
      view = new Views.SectionList
        collection: sections
        model: model
      window.VV = view
      layout.showChildView region, view
    response.fail ->
      MessageChannel.request 'danger', 'Failed to get sections'
    
  view_titles: ->
    @setup_layout_if_needed()
    @show_titles @layout, 'content'

  view_chapters: (tnum) ->
    @setup_layout_if_needed()
    @show_chapters @layout, 'content', tnum

  view_sections: (tnum, cnum) ->
    @setup_layout_if_needed()
    @show_sections @layout, 'content', tnum, cnum
    
  list_model_types: () ->
    mtypes = MscodeChannel.request 'all-models'
    
      
    

    
module.exports = Controller

  
