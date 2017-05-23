bookshelf = require './endpoints/classes/database'

User = bookshelf.Model.extend
  tableName: 'users'
  bcrypt:
    field: 'password'
  posts: ->
    @hasMany Post


Post = bookshelf.Model.extend
  tableName: 'posts'
  comments: ->
    @hasMany Comment
    
Comment = bookshelf.Model.extend
  tableName: 'comments'

DbDoc = bookshelf.Model.extend
  tableName: 'kdocs'

GenObject = bookshelf.Model.extend
  tableName: 'miscobjects'
,
  jsonColumns: ['content']
  
  
models =
  User: User
  Post: Post
  Comment: Comment
  DbDoc: DbDoc
  GenObject: GenObject
  
module.exports =
  knex: bookshelf.knex
  bookshelf: bookshelf
  models: models
