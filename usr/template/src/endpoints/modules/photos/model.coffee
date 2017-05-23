BaseModel = require('../../classes/base_model')
Author = require '../authors/model'
Series = require '../series/model'
Book = require '../books/model'

instanceProps =
  tableName: 'photos'
  hasTimestamps: true
  imageable: ->
    @morphTo 'imageable', Author, Series, Book
classProps =
  typeName: 'photos'
  filters: {}
  relations: [ 'imageable' ]
module.exports = BaseModel.extend(instanceProps, classProps)
