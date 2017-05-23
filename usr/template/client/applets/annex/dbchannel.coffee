Backbone = require 'backbone'

AppChannel = Backbone.Radio.channel 'annex'

apiroot = '/api/dev/misc'

Octokat = require 'octokat'

octo = undefined
logged_to_octo = false
if __DEV__
  window.octo = octo
  
AppChannel.reply 'create-connection', (name, password) ->
  octo = new Octokat
    username: name
    password: password
  logged_to_octo = true
  return octo
  
AppChannel.reply 'get-connection', ->
  octo

AppChannel.reply 'logged-in', ->
  logged_to_octo


  

class GenObject extends Backbone.Model
  url: ->
    "#{apiroot}/objects/#{@id}"

class GenObjectCollection extends Backbone.Collection
  url: "#{apiroot}/objects"
  
AppChannel.reply 'new-collection', ->
  new GenObjectCollection

object_collection = new GenObjectCollection
AppChannel.reply 'get-collection', ->
  object_collection


class Readme extends Backbone.Model
  urlRoot: "#{apiroot}/readmes"

AppChannel.reply 'new-readme-model', (id) ->
  new Readme
    id: id
    
  
class ReadmeCollection extends Backbone.Collection
  model: Readme
  url: "#{apiroot}/readmes"

readme_collection = new ReadmeCollection
AppChannel.reply 'get-readme-collection', ->
  return readme_collection
  
module.exports =
  GenObject: GenObject
  GenObjectCollection: GenObjectCollection
