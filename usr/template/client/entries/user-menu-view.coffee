Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Toolkit = require 'marionette.toolkit'
tc = require 'teacup'


guest_menu = tc.renderable (user) ->
  tc.li '.dropdown', ->
    tc.a '.dropdown-toggle', 'data-toggle':'dropdown', ->
      tc.text user.guestUserName
      tc.b '.caret'
    tc.ul '.dropdown-menu', ->
      tc.li ->
        tc.a href:user.loginUrl, 'login'

class UserMenuView extends Marionette.View
  tagName: 'ul'
  className: "nav navbar-nav"
  templateContext: ->
    loginUrl: @options.appConfig.loginUrl
    guestUserName: @options.appConfig.guestUserName
    # FIXME
    model: @model or new Backbone.Model
  template: (user) ->
    if user.model.isNew()
      return guest_menu user
    else
      # FIXME
      console.log "We have user"
      return guest_menu user
      
class UserMenuApp extends Toolkit.App
  onBeforeStart: ->
    @setRegion @options.parentApp.getView().getRegion 'usermenu'
    
  onStart: ->
    appConfig = @options.appConfig
    view = new UserMenuView
      appConfig: appConfig
    @showView view

module.exports = UserMenuApp
