_ = require 'underscore'
Backbone = require 'backbone'

BootstrapFormView = require 'tbirds/views/bsformview'

make_field_input_ui = require 'tbirds/util/make-field-input-ui'

tc = require 'teacup'
{ make_field_input
  make_field_textarea } = require 'tbirds/templates/forms'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'annex'

class BaseObjectEditor extends BootstrapFormView
  template: tc.renderable (model) ->
    make_field_input('name')(model)
    make_field_textarea('content')(model)
    tc.input '.btn.btn-default', type:'submit', value:"Submit"
    tc.div '.spinner.fa.fa-spinner.fa-spin'
    
  fieldList: ['name']
  ui: ->
    uiobject = make_field_input_ui @fieldList
    textareas =
      content: 'textarea[name="content"]'
    _.extend uiobject, textareas
    return uiobject
    
  updateModel: ->
    for field in @fieldList
      console.log 'field', field, @ui[field].val()
      @model.set field, @ui[field].val()
    @model.set 'content', JSON.parse @ui.content.val()
    
  afterSuccess: ->
    controller = AppChannel.request 'main-controller'
    controller.view_object @model.id
    
      
  onSuccess: (model) ->
    name = model.get 'name'
    MessageChannel.request 'success', "#{name} saved successfully."
    @afterSuccess model

class NewObjectView extends BaseObjectEditor
  createModel: ->
    MainChannel.request 'new-miscobj'
    
    
  saveModel: ->
    objects = MainChannel.request 'get-miscobj-collection'
    objects.add @model
    super

    
module.exports =
  BaseObjectEditor: BaseObjectEditor
  NewObjectView: NewObjectView
  

