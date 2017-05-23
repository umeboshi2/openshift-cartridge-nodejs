Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
ms = require 'ms'

{ MainController } = require 'tbirds/controllers'
{ ToolbarAppletLayout } = require 'tbirds/views/layout'
#navigate_to_url = require 'tbirds/util/navigate-to-url'

Views = require './views'
FormViews = require './formviews'
LoginView = require './loginview'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'annex'

btn = '.btn.btn-default'
fa = (name) ->
  ".fa.fa-#{name}"
  
class ToolbarView extends Backbone.Marionette.View
  template: tc.renderable () ->
    tc.div '.btn-group.btn-group-justified', ->
      tc.div "#list-objects-button#{btn}", ->
        tc.i fa 'list', ' Objects'
      tc.div "#list-readmes-button#{btn}", ->
        tc.i fa 'list', ' Readmes'
      tc.div "#new-object-button#{btn}", ->
        tc.i fa 'list', ' New Object'
  ui:
    list_repos_btn: '#list-repos-button'
    list_readmes_btn: '#list-readmes-button'
    list_objects_btn: '#list-objects-button'
    new_object_btn: '#new-object-button'
    
  events:
    'click @ui.list_repos_btn': 'list_repos'
    'click @ui.list_readmes_btn': 'list_readmes'
    'click @ui.list_objects_btn': 'list_objects'
    'click @ui.new_object_btn': 'new_object'

  list_objects: ->
    controller = AppChannel.request 'main-controller'
    controller.view_objects()
    MainChannel.request 'navigate-to-url', "#annex/objects"

  list_readmes: ->
    controller = AppChannel.request 'main-controller'
    controller.list_readmes()
    MainChannel.request 'navigate-to-url', "#annex/readmes"
    
  list_repos: ->
    controller = AppChannel.request 'main-controller'
    controller.list_repos()
    MainChannel.request 'navigate-to-url', "#annex/repos"

  new_object: ->
    controller = AppChannel.request 'main-controller'
    controller.new_object()
    MainChannel.request 'navigate-to-url', "#annex/objects/new"

class AppletLayout extends ToolbarAppletLayout
  template: tc.renderable () ->
    tc.div '.row', ->
      tc.div  '#main-toolbar.col-sm-6.col-sm-offset-3'
    tc.div '.row', ->
      tc.div '#main-header.col-sm-12'
    tc.div '.row', ->
      tc.div '#main-content.col-sm-10.col-sm-offset-1'
  regions: ->
    regions = super()
    regions.header = '#main-header'
    regions
    
class Controller extends MainController
  layoutClass: AppletLayout
  setup_layout_if_needed: ->
    super()
    @layout.showChildView 'toolbar', new ToolbarView

    
  show_objects: (layout, region) ->
    objects = MainChannel.request 'get-miscobj-collection'
    console.log "OBjects", objects
    if not objects.models.length
      response = objects.fetch()
      response.done ->
        view = new Views.GenObjList
          collection: objects
        console.log "layout, region", layout, region
        layout.showChildView region, view
      response.fail ->
        MessageChannel.request 'danger', 'Failed to get objects'
    else
      view = new Views.GenObjList
        collection: objects
      layout.showChildView region, view
    
  view_objects: ->
    @setup_layout_if_needed()
    @show_objects @layout, 'content'

  new_object: ->
    console.log "new_object"
    @setup_layout_if_needed()
    view = new FormViews.NewObjectView
    @layout.showChildView 'content', view
    
    
  view_object: (id) ->
    console.log "View_Object"
    @setup_layout_if_needed()
    model = MainChannel.request 'get-miscobj', id
    response = model.fetch()
    response.done =>
      view = new Views.JsonView
        model: model
      @layout.showChildView 'content', view
    response.fail ->
      MessageChannel.request 'danger', 'Failed to get object!'
    
  edit_object: (id) ->
    @setup_layout_if_needed()
    model = MainChannel.request 'get-miscobj', id
    response = model.fetch()
    response.done =>
      view = new Views.JsonView
        model: model
      @layout.showChildView 'content', view
    response.fail ->
      MessageChannel.request 'danger', 'Failed to get object!'

  login_view: ->
    @setup_layout_if_needed()
    view = new LoginView
    @layout.showChildView 'content', view

  default_view: ->
    if not AppChannel.request 'logged-in'
      @login_view()
    else
      #@view_objects()
      @view_user()
      
  view_user: ->
    @setup_layout_if_needed()
    octo = AppChannel.request 'get-connection'
    window.octo = octo
    response = octo.me.fetch()
    console.log 'octo.me.fetch()', response
    response.then (user) =>
      console.log "User is", user
      view = new Views.UserView
        model: new Backbone.Model user
      @layout.showChildView 'content', view
    
  _list_repos: ->
    @setup_layout_if_needed()
    octo = AppChannel.request 'get-connection'
    window.octo = octo
    response = octo.user.repos.fetch()
    response.done (data) ->
      console.log 'response', response
      console.log "data", data
      objs = MainChannel.request 'get-miscobj-collection'
      for item in data.items
        model = new Backbone.Model
        model.set 'content', item
        objs.add model
        model.save()
      
    response.fail ->
      MessageChannel.request 'danger', 'Failed to get object!'
      console.log 'response', response
      
  list_repos: ->
    if not AppChannel.request 'logged-in'
      @login_view()
    else
      @_list_repos()
    
  _list_readmes: ->
    @setup_layout_if_needed()
    collection = AppChannel.request 'get-readme-collection'
    response = collection.fetch()
    if not collection.models.length
      response = collection.fetch()
      response.done =>
        view = new Views.ReadmeList
          collection: collection
        @layout.showChildView 'content', view
      response.fail ->
        MessageChannel.request 'danger', 'Failed to get readmes!'
    else
      view = new Views.ReadmeList
        collection: collection
      @layout.showChildView 'content', view
      
  list_readmes: ->
    @_list_readmes()

  view_readme: (id) ->
    console.log "View Readme", id
    @setup_layout_if_needed()
    model = AppChannel.request 'new-readme-model', id
    response = model.fetch()
    response.done =>
      view = new Views.ReadmeView
        model: model
      @layout.showChildView 'content', view
    response.fail ->
      MessageChannel.request 'danger', 'Failed to get readme!'
    
    
  
module.exports = Controller

  
