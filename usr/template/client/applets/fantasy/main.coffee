_ = require 'underscore'
Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'

require './dbchannel'
Controller = require './controller'
models = require('./common').models

APPNAME = 'fantasy'
MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel APPNAME

make_routes = (collection, resource) ->
  routes =
    "#{APPNAME}/#{collection}": "list_#{collection}"
    #"#{APPNAME}/#{collection}/new": "new_#{resource}"
    "#{APPNAME}/#{collection}/view/:id": "view_#{resource}"
    #"#{APPNAME}/#{collection}/edit/:id": "edit_#{resource}"
  return routes

class Applet extends TkApplet
  Controller: Controller
  Router: Marionette.AppRouter
  appRoutes: ->
    _.extend {fantasy: 'list_authors'},
      make_routes 'authors', 'author'
      make_routes 'books', 'book'
      make_routes 'chapters', 'chapter'
      make_routes 'photos', 'photo'
      make_routes 'series', 'series'
      make_routes 'stores', 'store'
      
  onBeforeStart: ->
    super arguments
    MainChannel.reply "applet:#{APPNAME}:router", =>
      @router
    MainChannel.reply "applet:#{APPNAME}:controller", =>
      @router.controller

module.exports = Applet
