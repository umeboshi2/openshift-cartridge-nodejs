Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

navigate_to_url = require 'tbirds/util/navigate-to-url'
make_field_input_ui = require 'tbirds/util/make-field-input-ui'
{ form_group_input_div } = require 'tbirds/templates/forms'
BootstrapFormView = require 'tbirds/views/bsformview'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'annex'

login_form =  tc.renderable (user) ->
  tc.form ->
    form_group_input_div
      input_id: 'input_username'
      label: 'User Name'
      input_attributes:
        name: 'username'
        placeholder: 'User Name'
    form_group_input_div
      input_id: 'input_password'
      label: 'Password'
      input_attributes:
        name: 'password'
        type: 'password'
        placeholder: 'Type your password here....'
    tc.input '.btn.btn-default', type:'submit', value:'login'
    tc.div '.spinner.fa.fa-spinner.fa-spin'


class LoginView extends BootstrapFormView
  template: login_form
  fieldList: ['username', 'password']
  ui: ->
    uiobject = make_field_input_ui @fieldList
    return uiobject

  createModel: ->
    new Backbone.Model

  updateModel: ->
    console.log 'updateModel called'
    @model.set 'username', @ui.username.val()
    @model.set 'password', @ui.password.val()

  saveModel: ->
    username  = @model.get 'username'
    password = @model.get 'password'
    # override login info in development mode
    # FIXME, put this in config for enable disablexs
    if __DEV__
      console.warn "override login"
      devauth = require '../../../.auth'
      username = devauth.username
      password = devauth.password
    AppChannel.request 'create-connection', username, password
    octo = AppChannel.request 'get-connection'
    @trigger 'save:form:success', octo
    
  onSuccess: ->
    navigate_to_url '#annex/repos'
    
     
    
module.exports = LoginView
