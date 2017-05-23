Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'


Controller = require './controller'


MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'msleg'



class Router extends Marionette.AppRouter
  appRoutes:
    'msleg': 'start'
    'msleg/listmeas': 'list_measures'
    
class Applet extends TkApplet
  Controller: Controller
  Router: Router

  onBeforeStart: ->
    super arguments
    MainChannel.reply 'applet:annex:router', =>
      @router
    MainChannel.reply 'applet:annex:controller', =>
      @router.controller
    AppChannel.reply 'main-controller', =>
      console.warn "Stop using 'main-controller' request on AppChannel"
      @router.controller
    AppChannel.reply 'list-measures', =>
      @router.controller.list_measures()

MainChannel.reply 'applet:msleg:route', () ->
  console.warn "Don't use applet:msleg:route"
  controller = new Controller MainChannel
  AppChannel.reply 'list-measures', ->
    controller.list_measures()
  router = new Router
    controller: controller
    
module.exports = Applet
