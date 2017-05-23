_ = require 'underscore'
Backbone = require 'backbone'

BBJsonApi = require 'backbone-jsonapi'
BBJsonApi Backbone, _

models = require('./common').models

AppChannel = Backbone.Radio.channel 'fantasy'

apiBase = "/api/dev/ep"
apiVersion = 'v1'
apiPath = "#{apiBase}/#{apiVersion}"

convert_link = (base, link) ->
  orig = link
  while link.startsWith '/'
    link = link.substr 1
  return "#{base}/#{link}"

#class BaseModel extends Backbone.Model
class BaseModel extends Backbone.JsonApiModel
  parse: (response) ->
    data = response?.data or response
    #console.log "response", response
    #console.log 'data', data, @
    # hard set the url to self
    @url = convert_link apiBase, data.links.self
    @modelType = data.type
    @links = data.links
    @relationships = data.relationships
    attributes = data.attributes
    attributes.id = data.id
    #return attributes
    return data
    
  makeRelation: (name) ->
    rel = @relationships[name]
    console.log "REL", rel
    
#class BaseModel extends Backbone.JsonApiModel
#  foo: 'bar'

  
class BaseCollection extends Backbone.JsonApiCollection

make_model_requests = (channel, name, Model, Collection) ->
  collection = new Collection
  channel.reply "db:#{name}:collection", ->
    collection
  channel.reply "db:#{name}:new", ->
    new Model
  channel.reply "db:#{name}:get", (id) ->
    new Model
      id: id

establish_model = (name) ->
  modelPath = "#{apiPath}/#{name}"
  class Model extends BaseModel
    urlRoot: modelPath
  class Collection extends BaseCollection
    url: modelPath
    model: Model
  make_model_requests AppChannel, name, Model, Collection
    
models.forEach (model) ->
  establish_model model
  
module.exports = {}

  

