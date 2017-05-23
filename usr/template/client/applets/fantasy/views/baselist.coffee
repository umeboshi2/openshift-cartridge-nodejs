Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'fantasy'


class BaseEntry extends Marionette.View
  ui:
    item: '.list-group-item'
  templateContext: ->
    collectionName: @options.collectionName
    entryAttribute: @options.entryAttribute
    itemBaseViewUrl: "#fantasy/#{@options.collectionName}/view"
  template: tc.renderable (model) ->
    tc.div '.list-group-item', ->
      tc.span ->
        title = model.attributes[model.entryAttribute]
        tc.a href:"#{model.itemBaseViewUrl}/#{model.id}", title
        
class BaseCollectionView extends Marionette.CollectionView
  childView: BaseEntry
  childViewOptions: ->
    @options
    

class BaseList extends Marionette.View
  regions:
    list: '.list-group'
    header: '.listview-header'
  templateContext: ->
    headerText: @options.headerText
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.a href:"#fantasy", "#{model.headerText}"
    tc.div '.list-group'

  onRender: ->
    options = @options
    options.collection = @collection
    view = new BaseCollectionView options
    @showChildView 'list', view
    
  
module.exports = BaseList

