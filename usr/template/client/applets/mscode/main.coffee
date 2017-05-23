Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'

require './dbchannel'
Controller = require './controller'


MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'mscode'



class Router extends Marionette.AppRouter
  appRoutes:
    'mscode': 'view_titles'
    'mscode/titles/:tnum': 'view_chapters'
    'mscode/titles/:tnum/chapters/:cnum': 'view_sections'
    
      
class Applet extends TkApplet
  Controller: Controller
  Router: Router

  onBeforeStart: ->
    super arguments
    AppChannel.reply 'main-controller', =>
      console.warn "Stop using 'main-controller' request on AppChannel"
      @router.controller
  
        
MainChannel.reply 'applet:mscode:route', () ->
  console.warn "Don't use applet:mscode:route"
  controller = new Controller MainChannel
  AppChannel.reply 'main-controller', ->
    controller
  router = new Router
    controller: controller

module.exports = Applet
