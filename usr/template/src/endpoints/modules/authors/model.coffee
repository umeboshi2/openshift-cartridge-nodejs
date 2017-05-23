BaseModel = require('../../classes/base_model')
instanceProps =
  tableName: 'authors'
  hasTimestamps: true
  books: ->
    @hasMany require('../books/model')
  photos: ->
    @morphMany require('../photos/model'), 'imageable'
classProps =
  typeName: 'authors'
  createWithRandomBook: (params) ->
    # this should be in a transaction
    @create(params).then (model) ->
      require('../books/model').create(
        title: Math.random().toString(36).slice(-8)
        date_published: (new Date).toISOString().slice(0, 10)
        author_id: model.get('id')).return model
  filters:
    id: (qb, value) ->
      qb.whereIn 'id', value
    name: (qb, value) ->
      qb.whereIn 'name', value
    alive: (qb, value) ->
      if value
        qb.whereNull 'date_of_death'
      else
        qb.whereNotNull 'date_of_death'
    dead: (qb, value) ->
      @alive qb, !value
    date_of_birth: (qb, value) ->
      qb.whereIn 'date_of_birth', value
    date_of_death: (qb, value) ->
      qb.whereIn 'date_of_death', value
    born_before: (qb, value) ->
      qb.where 'date_of_birth', '<', value
    born_after: (qb, value) ->
      qb.where 'date_of_birth', '>', value
  relations: [
    'books'
    'books.chapters'
    'photos'
  ]
module.exports = BaseModel.extend(instanceProps, classProps)
