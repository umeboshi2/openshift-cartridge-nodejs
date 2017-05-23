BaseModel = require('../../classes/base_model')
instanceProps = 
  tableName: 'books'
  hasTimestamps: true
  author: ->
    @belongsTo require('../authors/model')
  series: ->
    @belongsTo require('../series/model')
  chapters: ->
    @hasMany require('../chapters/model')
  firstChapter: ->
    @hasMany(require('../chapters/model')).query (qb) ->
      qb.where 'ordering', 1
      return
  stores: ->
    @belongsToMany require('../stores/model')
  photos: ->
    @morphMany require('../photos/model'), 'imageable'
classProps = 
  typeName: 'books'
  filters:
    author_id: (qb, value) ->
      qb.whereIn 'author_id', value
    series_id: (qb, value) ->
      qb.whereIn 'series_id', value
    date_published: (qb, value) ->
      qb.whereIn 'date_published', value
    published_before: (qb, value) ->
      qb.where 'date_published', '<', value
    published_after: (qb, value) ->
      qb.where 'date_published', '>', value
    title: (qb, value) ->
      qb.whereIn 'title', value
  relations: [
    'chapters'
    'firstChapter'
    'series'
    'author'
    'stores'
    'photos'
  ]
module.exports = BaseModel.extend(instanceProps, classProps)
