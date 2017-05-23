Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'

require './dbchannel'
Controller = require './controller'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'annex'



class Router extends Marionette.AppRouter
  appRoutes:
    'annex': 'default_view'
    'annex/default': 'default_view'
    'annex/repos': 'list_repos'
    'annex/readmes': 'list_readmes'
    'annex/readmes/view/:id': 'view_readme'
    'annex/objects': 'view_objects'
    'annex/objects/new': 'new_object'
    'annex/objects/view/:id': 'view_object'
    'annex/objects/edit/:id': 'edit_object'

  onRoute: (name, path, args) ->
    console.log "onRoute", name, path, args
        
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
    if __DEV__
      console.warn "override login"
      devauth = require '../../../.auth'
      username = devauth.username
      password = devauth.password
      AppChannel.request 'create-connection', username, password

MainChannel.reply 'applet:annex:route', () ->
  console.warn "Don't use applet:annex:route"
  controller = new Controller MainChannel
  AppChannel.reply 'main-controller', ->
    controller
  router = new Router
    controller: controller
  if __DEV__
    console.warn "override login"
    devauth = require '../../../.auth'
    username = devauth.username
    password = devauth.password
    AppChannel.request 'create-connection', username, password

module.exports = Applet
