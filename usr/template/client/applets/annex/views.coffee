_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
JView = require 'json-view'
require 'json-view/devtools.css'
marked = require 'marked'

#navigate_to_url = require 'tbirds/util/navigate-to-url'
ConfirmDeleteModal = require 'tbirds/delete-named-model'

show_modal = (view, backdrop=false) ->
  app = MainChannel.request 'main:app:object'
  modal_region = app.getView().getRegion 'modal'
  modal_region.backdrop = backdrop
  modal_region.show view


MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'annex'

class JsonView extends Backbone.Marionette.View
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.text "#{model.name}"
    tc.div '.panel'
  ui:
    body: '.panel'
    
  onDomRefresh: ->
    view = new JView @model.get 'content'
    @ui.body.prepend view.dom

class GenObjEntry extends Backbone.Marionette.View
  template: tc.renderable (model) ->
    item_btn = ".btn.btn-default.btn-xs"
    tc.div '.genobj.list-group-item', ->
      tc.span ->
        title = "Object: #{model?.name or model.content?.name}"
        tc.a href:"#annex/objects/view/#{model.id}", title
      tc.div '.btn-group.pull-right', ->
        tc.button ".edit-item.#{item_btn}.btn-info.fa.fa-edit", 'edit'
        tc.button ".delete-item.#{item_btn}.btn-danger.fa.fa-close", 'delete'
  ui:
    edit_item: '.edit-item'
    delete_item: '.delete-item'
    item: '.list-item'
    
  events: ->
    'click @ui.edit_item': 'edit_item'
    'click @ui.delete_item': 'delete_item'
    
  edit_item: ->
    controller = AppChannel.request 'main-controller'
    controller.edit_object @model.id
    MainChannel.request 'navigate-to-url', "#annex/objects/edit/#{@model.id}"
    
  delete_item: ->
    if __DEV__
      console.log "delete_object", @model
    view = new ConfirmDeleteModal
      model: @model
    if __DEV__
      console.log 'modal view', view
    show_modal view, true
  
class GenObjCollection extends Backbone.Marionette.CollectionView
  childView: GenObjEntry

class GenObjList extends Backbone.Marionette.View
  regions:
    list: '.list-group'
    header: '.listview-header'
  template: tc.renderable ->
    tc.div '.listview-header', ->
      tc.a href:"#annex", "General Objects"
    tc.div '.list-group'

  onRender: ->
    view = new GenObjCollection
      collection: @collection
    @showChildView 'list', view
    

class ReadmeEntry extends Backbone.Marionette.View
  template: tc.renderable (model) ->
    item_btn = ".btn.btn-default.btn-xs"
    tc.div '.list-group-item', ->
      tc.span ->
        title = "Readme: #{model?.name or model.content}"
        tc.a href:"#annex/readmes/view/#{model.id}", title
  ui:
    item: '.list-group-item'
    
class ReadmeCollection extends Backbone.Marionette.CollectionView
  childView: ReadmeEntry

class ReadmeList extends Backbone.Marionette.View
  regions:
    list: '.list-group'
    header: '.listview-header'
  template: tc.renderable ->
    tc.div '.listview-header', ->
      tc.a href:"#annex", "ReadMe's"
    tc.div '.list-group'

  onRender: ->
    view = new ReadmeCollection
      collection: @collection
    @showChildView 'list', view
    


class ReadmeView extends Backbone.Marionette.View
  template: tc.renderable (doc) ->
    tc.article '.document-view.content', ->
      tc.div '.body', ->
        tc.raw marked doc.content


class UserView extends Backbone.Marionette.View
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.text "#{model.name}"
    tc.div '.panel'
  ui:
    body: '.panel'
    
  onDomRefresh: ->
    view = new JView @model.attributes
    @ui.body.prepend view.dom
  
module.exports =
  JsonView: JsonView
  GenObjList: GenObjList
  ReadmeList: ReadmeList
  ReadmeView: ReadmeView
  UserView: UserView
