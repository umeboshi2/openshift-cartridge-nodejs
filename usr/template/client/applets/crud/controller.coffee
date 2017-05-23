Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
ms = require 'ms'

{ MainController } = require 'tbirds/controllers'
SlideDownRegion = require 'tbirds/regions/slidedown'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
CrudChannel = Backbone.Radio.channel 'crud'

class AppletLayout extends Backbone.Marionette.View
  template: tc.renderable () ->
    tc.div '#main-content.col-sm-12'
  regions: ->
    region = new SlideDownRegion
      el: '#main-content'
    region.slide_speed = ms '.01s'
    content: region
  

class Controller extends MainController
  layoutClass: AppletLayout
  appRoutes:
    'crud': 'list_models'
    
  list_model_types: () ->
    @setup_layout_if_needed()
    mtypes = CrudChannel.request 'all-models'
    require.ensure [], () =>
      { MtypeCollectionView } = require './views'
      response = mtypes.fetch()
      response.done () =>
        view = new MtypeCollectionView
          collection: mtypes
        @layout.showChildView 'content', view
      response.fail ->
        MessageChannel.request 'danger', 'Failed to get models'
    # name the chunk
    , 'crud-view-list-model-types'
    
      
    
    console.log "list_model_types"

  list_models: (name) ->
    console.log "list_models of #{name}"
    collection = CrudChannel.request "make-model-collection", name
    @setup_layout_if_needed()
    require.ensure [], () =>
      { make_list_viewclass } = require './views'
      response = collection.fetch()
      response.done () =>
        vclass = make_list_viewclass name
        view = new vclass
          collection: collection
        @layout.showChildView 'content', view
      response.fail ->
        MessageChannel.request 'danger', "Failed to get #{name}"
    # name the chunk
    , 'crud-view-list-models'

  view_model: (name, id) ->
    console.log "VIEW_MODEL", name, id
    
module.exports = Controller

  
