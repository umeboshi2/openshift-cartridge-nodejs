Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
Url = require 'url'
MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'msleg'

########################################

make_info = tc.renderable (model) ->
  level = if model.active then "success" else "danger"
  tc.div ".info.panel.panel-#{level}", unitid:model.id, ->
    name = model.id
    tc.div ".panel-heading", name
        
########################################

class SimpleInfoView extends Backbone.Marionette.View
  ui:
    info: '.info'

  triggers:
    'click @ui.info': 'click:info'

  events:
    'click @ui.info': 'view_something'
    
  view_something: (event) ->
    # FIXME - determine proper target for event
    unitid = event.currentTarget.attributes.unitid.value
    AppChannel.request 'view-something', unitid
    
  template: tc.renderable (model) ->
    #tc.div '.info.listview-list-entry', ->
    level = 'info'
    if not model.active
      level = 'danger'
    make_info model

  onDomRefresh: ->
    @ui.info.css
      cursor: 'pointer'
    
class ListView extends Backbone.Marionette.CompositeView
  childView: SimpleInfoView
  template: tc.renderable () ->
    tc.div '#proplist-container.listview-list.col-sm-10.col-sm-offset-1'
  childViewContainer: '#proplist-container'
  ui:
    proplist: '#proplist-container'

module.exports = PropListView
