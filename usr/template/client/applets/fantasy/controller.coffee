tc = require 'teacup'

{ MainController } = require 'tbirds/controllers'
navigate_to_url = require 'tbirds/util/navigate-to-url'
capitalize = require 'tbirds/util/capitalize'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'fantasy'

{ ToolbarAppletLayout } = require 'tbirds/views/layout'

make_model_entry = (name) ->
  name: capitalize name
  url: "#fantasy/#{name}"
  icon: 'list'


toolbar_data = new Backbone.Model
  entries: [
    {
      name: 'Authors'
      url: '#fantasy/authors'
      icon: 'list'
    }
    {
      name: 'Books'
      url: '#fantasy/books'
      icon: 'list'
    }
    {
      name: 'Chapters'
      url: '#fantasy/chapters'
      icon: 'list'
    }
    {
      name: 'Photos'
      url: '#fantasy/photos'
      icon: 'list'
    }
    {
      name: 'Series'
      url: '#fantasy/series'
      icon: 'list'
    }
    {
      name: 'Stores'
      url: '#fantasy/stores'
      icon: 'list'
    }
    ]

toolbar_template = tc.renderable (model) ->
  tc.div '.btn-group.btn-group-justified', ->
    for entry in model.entries
      tc.div '.toolbar-button.btn.btn-default',
      'button-url': entry.url, ->
        tc.span ".fa.fa-#{entry.icon}", ' ' + entry.name

class ToolbarView extends Backbone.Marionette.View
  template: toolbar_template
  ui:
    toolbarButton: '.toolbar-button'
  events:
    'click @ui.toolbarButton': 'toolbarButtonPressed'
  toolbarButtonPressed: (event) ->
    console.log "toolbarButtonPressed", event
    url = event.currentTarget.getAttribute 'button-url'
    navigate_to_url url
    

class Controller extends MainController
  layoutClass: ToolbarAppletLayout
  setup_layout_if_needed: ->
    super()
    view = new ToolbarView
      model: toolbar_data
    @layout.showChildView 'toolbar', view

  view_model: (options) ->
    cname = options.collectionName
    @setup_layout_if_needed()
    require.ensure [], () =>
      View = require './views/base-model-view'
      model = AppChannel.request "db:#{cname}:get", options.id
      console.log "model is", model
      options.model = model
      response = model.fetch()
      response.done =>
        console.log "fetched model is", model
        view = new View options
        @layout.showChildView 'content', view
      response.fail ->
        MessageChannel.request 'danger', "Failed to load author #{id}"
    # name the chunk
    , 'fantasy-view-doc-page'
      
  list_models: (options) ->
    cname = options.collectionName
    @setup_layout_if_needed()
    collection = AppChannel.request "db:#{cname}:collection"
    console.log "List #{cname}", collection
    options.collection = collection
    require.ensure [], () =>
      ListView = require './views/baselist'
      view = new ListView options
      response = collection.fetch()
      response.done =>
        @layout.showChildView 'content', view
      response.fail ->
        MessageChannel.request 'danger', "Failed to load #{cname}."
    # name the chunk
    , 'fantasy-view-list-models'
    
  list_authors: ->
    options =
      collectionName: 'authors'
      headerText: "***Authors!!!"
      entryAttribute: 'name'
      bornAttribute: 'date_of_birth'
    @list_models options

  view_author: (id) ->
    options =
      id: id
      collectionName: 'authors'
      headerText: "Here are some authors"
      entryAttribute: 'name'
      bornAttribute: 'date_of_birth'
    @view_model options

  list_books: ->
    options =
      collectionName: 'books'
      headerText: "Here are some books"
      entryAttribute: 'title'
      bornAttribute: 'date_published'
    @list_models options
    
  view_book: (id) ->
    options =
      id: id
      collectionName: 'books'
      headerText: "Here are some books"
      entryAttribute: 'title'
      bornAttribute: 'date_published'
    @view_model options

  list_chapters: ->
    options =
      collectionName: 'chapters'
      headerText: "Here are some books"
      entryAttribute: 'title'
      bornAttribute: 'date_published'
    @list_models options
    
  view_chapter: (id) ->
    options =
      id: id
      collectionName: 'chapters'
      headerText: "Here are some books"
      entryAttribute: 'title'
      bornAttribute: 'date_published'
    @view_model options

  list_photos: ->
    options =
      collectionName: 'photos'
      headerText: "Here are some books"
      entryAttribute: 'title'
      bornAttribute: 'date_published'
    @list_models options
    
  view_photo: (id) ->
    options =
      id: id
      collectionName: 'photos'
      headerText: "Here are some books"
      entryAttribute: 'title'
      bornAttribute: 'date_published'
    @view_model options

  list_series: ->
    options =
      collectionName: 'series'
      headerText: "Here are some books"
      entryAttribute: 'title'
      bornAttribute: 'date_published'
    @list_models options
    
  view_series: (id) ->
    options =
      id: id
      collectionName: 'series'
      headerText: "Here are some books"
      entryAttribute: 'title'
      bornAttribute: 'date_published'
    @view_model options

  list_stores: ->
    options =
      collectionName: 'stores'
      headerText: "Here are some books"
      entryAttribute: 'name'
      bornAttribute: 'date_published'
    @list_models options
    
  view_store: (id) ->
    options =
      id: id
      collectionName: 'stores'
      headerText: "Here are some books"
      entryAttribute: 'name'
      bornAttribute: 'date_published'
    @view_model options

      
module.exports = Controller

