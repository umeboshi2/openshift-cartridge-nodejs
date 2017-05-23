BaseModel = require('../../classes/base_model')
instanceProps = 
  tableName: 'chapters'
  hasTimestamps: true
  book: ->
    @belongsTo require('../books/model')
classProps = 
  typeName: 'chapters'
  filters:
    book_id: (qb, value) ->
      qb.whereIn 'book_id', value
    title: (qb, value) ->
      qb.whereIn 'title', value
    ordering: (qb, value) ->
      qb.whereIn 'ordering', value
  relations: [ 'book' ]
module.exports = BaseModel.extend(instanceProps, classProps)
