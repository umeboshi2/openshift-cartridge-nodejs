Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'

require './dbchannel'
Controller = require './controller'


MainChannel = Backbone.Radio.channel 'global'
CrudChannel = Backbone.Radio.channel 'crud'



class Router extends Marionette.AppRouter
  appRoutes:
    'crud': 'list_model_types'
    'crud/:model': 'list_models'
    'crud/:model/view/:id': 'view_model'
    #'crud/:model/new': 'new_model'
    #'crud/:model/edit/:id': 'edit_model'
    
        
class Applet extends TkApplet
  Controller: Controller
  Router: Router

  onBeforeStart: ->
    super arguments
    CrudChannel.reply 'main-controller', =>
      console.warn "Stop using 'main-controller' request on AppChannel"
      @router.controller
    MainChannel.reply 'applet:crud:router', =>
      @router
    MainChannel.reply 'applet:crud:controller', =>
      @router.controller

MainChannel.reply 'applet:crud:route', () ->
  console.warn "Don't use applet:crud:route"
  controller = new Controller MainChannel
  CrudChannel.reply 'main-controller', ->
    controller
  router = new Router
    controller: controller

module.exports = Applet
