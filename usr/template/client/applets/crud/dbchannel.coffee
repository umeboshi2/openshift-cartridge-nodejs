Backbone = require 'backbone'

{ make_dbchannel } = require 'tbirds/crud/basecrudchannel'

MainChannel = Backbone.Radio.channel 'global'
CrudChannel = Backbone.Radio.channel 'crud'

apiroot = '/api/dev/misc'

create_db_objects = (models) ->
  url = "/api/dev/misc/#{models}"
  class Model extends Backbone.Model
    urlRoot: url
  class Collection extends Backbone.Collection
    model: Model
    url: url
  return model: Model, collection: Collection

class ModelTypes extends Backbone.Collection
  url: "#{apiroot}/all-models"
CrudChannel.reply 'all-models', ->
  new ModelTypes
    
make_model_collection = (mclass) ->
  class Models extends Backbone.Collection
    url: "#{apiroot}/#{mclass}"
  return new Models

CrudChannel.reply 'make-model-collection', (model) ->
  make_model_collection model
  

add_model_to_channel = (channel, modelname) ->
  dbobjs = create_db_objects "#{modelname}s"
  make_dbchannel channel, modelname, dbobjs.model, dbobjs.collection


module.exports = null
