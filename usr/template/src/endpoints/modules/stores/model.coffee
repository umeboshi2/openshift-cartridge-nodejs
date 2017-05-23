BaseModel = require('../../classes/base_model')
instanceProps = 
  tableName: 'stores'
  hasTimestamps: true
  books: ->
    @belongsToMany require('../books/model')
classProps = 
  typeName: 'stores'
  filters: {}
  relations: [
    'books'
    'books.author'
  ]
module.exports = BaseModel.extend(instanceProps, classProps)
