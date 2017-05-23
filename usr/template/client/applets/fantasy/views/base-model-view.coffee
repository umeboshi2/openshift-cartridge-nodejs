Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'fantasy'

class InfoView extends Marionette.View
  ui:
    item: '.list-group-item'
  template: tc.renderable (model) ->
    tc.div '.list-group-item', ->
      tc.span ->
        title = model.name
        tc.a href:"#fantasy/authorsFIXME/#{model.id}", title

class RelationView extends Marionette.View

class MainView extends Marionette.View
  templateContext: ->
    options = @options
    options.itemBaseViewUrl = "#fantasy/#{options.collectionName}/view"
    options
    
  template: tc.renderable (model) ->
    tc.div '.list-group-item', ->
      tc.span ->
        title = model.attributes[model.entryAttribute]
        tc.a href:"#{model.itemBaseViewUrl}/#{model.id}", title
      tc.span " (#{model.attributes[model.bornAttribute]})"

module.exports = MainView

