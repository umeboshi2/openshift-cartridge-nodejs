$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

xml = require 'xml2js-parseonly/src/xml2js'

scroll_top_fast = require 'tbirds/util/scroll-top-fast'
{ MainController } = require 'tbirds/controllers'

#Collections = require './collections'
{ get_xml } = require './collections'

cfg_env = 'production'
if __DEV__
  cfg_env = 'development'
config = require('./config')[cfg_env]

AppChannel = Backbone.Radio.channel 'msleg'

cl = require './collections'
window.tm = new cl.TestRssModel


class HeaderView extends Backbone.Marionette.View
  template: tc.renderable (model) ->
    tc.div '.listview-header', model.title
    
make_header_view = (title) ->
  model = new Backbone.Model
    title: title
  view = new HeaderView
    model: model
  view
  

class AppLayout extends Backbone.Marionette.View
  template: tc.renderable ->
    tc.div '#header'
    tc.div '#main-content', ->
      tc.h1 ->
        tc.text 'Loading ...'
        tc.i '.fa.fa-spinner.fa-spin'
  regions:
    header: '#header'
    content: '#main-content'

class Controller extends MainController
  layoutClass: AppLayout
  house_members: undefined
  

  set_header: (title) ->
    view = make_header_view title
    @layout.showChildView 'header', view

  start: ->
    @setup_layout_if_needed()
    # start with list_measures
    if not @house_members?
      # grab xml if collection undefined
      # DEBUG - go straight to description
      if __DEV__ and false
        get_xml config.hr_membs @view_something, "id"
      else
        get_xml config.hr_membs, @list_measures
    else
      # data exists, go ahead and make list
      @list_measures()
      
  list_measures: (json) =>
    @setup_layout_if_needed()
    @set_header 'House Members'
    #@layout.showChildView 'content', view
    if not @house_members?
      members = parse_hr_membs json
      @house_members = new Backbone.Collection members
      window.hrmember = @house_members
    else
      console.log "members loaded."
    scroll_top_fast()
    
  view_something: (m_id) =>
    if __DEV__
      console.log "m_id", m_id
    @setup_layout_if_needed()
    @set_header 'Some View'
    #@layout.showChildView 'content', view
    scroll_top_fast()
    
module.exports = Controller

