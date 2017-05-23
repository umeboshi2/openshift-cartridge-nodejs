BaseModel = require('../../classes/base_model')
instanceProps = 
  tableName: 'series'
  hasTimestamps: true
  books: ->
    @hasMany require('../books/model')
  photos: ->
    @morphOne require('../photos/model'), 'imageable'
classProps = 
  typeName: 'series'
  filters: title: (qb, value) ->
    qb.whereIn 'title', value
  relations: [
    'books'
    'photos'
  ]
module.exports = BaseModel.extend(instanceProps, classProps)
