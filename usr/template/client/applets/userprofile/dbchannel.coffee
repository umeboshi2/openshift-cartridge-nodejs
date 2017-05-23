$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

{ User
  CurrentUser } = require 'tbirds/users'
  
MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
UserProfileChannel = Backbone.Radio.channel 'userprofile'


UserProfileChannel.reply 'update-user-config', ->
  console.log 'update-user-config called'
  

    
module.exports = {}
