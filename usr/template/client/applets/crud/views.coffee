_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

MainChannel = Backbone.Radio.channel 'global'
CrudChannel = Backbone.Radio.channel 'crud'
class SimpleMeetingView extends Backbone.Marionette.View
  template: tc.renderable (model) ->
    name = "meeting"
    item_btn = ".btn.btn-default.btn-xs"
    tc.li ".list-group-item.#{name}-item", ->
      tc.span ->
        tc.a href:"#hubby/viewmeeting/#{model.id}", model.title

class ListMeetingsView extends Backbone.Marionette.CompositeView
  childView: SimpleMeetingView
  template: tc.renderable () ->
    tc.div '.listview-header', ->
      tc.text "Meetings"
    tc.hr()
    tc.ul "#meetings-container.list-group"



class MtypeView extends Backbone.Marionette.View
  template: tc.renderable (model) ->
    tc.div '.model-type', ->
      tc.a href:"#crud/#{model.name}", model.name
      tc.span "Table: #{model.table_name}"
      tc.ul ->
        for a in model.config.attributes
          tc.li a
          

class MtypeCollectionView extends Backbone.Marionette.CollectionView
  childView: MtypeView
  template: tc.renderable (model) ->
    tc.div '.model-types'

make_item_template = (model_name) ->
  tc.renderable (model) ->
    tc.li '.model.list-group-item', ->
      tc.dl '.dl-horizontal', ->
        for prop of model
          if prop in ['name', 'title', 'number']
            tc.dt prop
            tc.dd model[prop]
      tc.a href:"#crud/#{model_name}/view/#{model.id}", 'view'

make_list_template = (model_name) ->
  tc.renderable () ->
    tc.div '.listview-header', ->
      tc.text "#{model_name}s"
    tc.hr()
    tc.ul ".model-list.list-group"
    
class ItemView extends Backbone.Marionette.View
  template: tc.renderable (model) ->

make_item_viewclass = (model_name) ->
  class IView extends Backbone.Marionette.View
    template: make_item_template model_name
  return IView
  
make_list_viewclass = (model_name) ->
  class LView extends Backbone.Marionette.CollectionView
    childView: make_item_viewclass model_name
    template: make_list_template model_name
  LView

module.exports =
  MtypeCollectionView: MtypeCollectionView
  make_list_viewclass: make_list_viewclass
  
  
