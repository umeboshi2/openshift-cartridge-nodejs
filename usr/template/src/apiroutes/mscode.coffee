_ = require 'underscore'
Promise = require 'bluebird'
express = require 'express'

router = express.Router()

Tdb = require '../../assets/mississippi/db.json'

router.get '/dbtitles', (req, res) ->
  titles = []
  for tnum of Tdb
    data = Tdb[tnum]
    tobj =
      id: tnum
      title: data.title
    titles.push tobj
  res.json titles

router.get '/dbchapters/:tnum', (req, res) ->
  data = req.tdata
  chapters = []
  for cnum of req.tdata.chapters
    data = req.tdata.chapters[cnum]
    cobj =
      id: cnum
      title: data.title
      tnum: req.tnum
    chapters.push cobj
  res.json chapters

router.get '/dbsections/:tnum/:cnum', (req, res) ->
  data = req.cdata
  sections = []
  for csid of req.cdata.csections
    data = req.cdata.csections[csid]
    cobj =
      id: csid
      title: data.title
      tnum: req.tnum
    sections.push cobj
  res.json sections
  
  
router.get '/dbtitles/:tnum', (req, res) ->
  data = Tdb[req.tnum]
  console.log "DATA dbtitles", data
  res.json data

router.param 'tnum', (req, res, next, value) ->
  req.tnum = value
  req.tdata = Tdb[req.tnum]
  next()

router.param 'cnum', (req, res, next, value) ->
  req.cnum = value
  req.cdata = Tdb[req.tnum].chapters[req.cnum]
  next()
  
router.param 'models', (req, res, next, value) ->
  req.ModelClass = req.app.locals.sql.models[value]
  req.ModelRoute = value
  next()

router.param 'id', (req, res, next, value) ->
  options =
    where:
      id: req.params.id
  if 'include' of req.query
    includes = []
    if req.query.include is '*'
      for rel of req.ModelClass.associations
        includes.push req.ModelClass.associations[rel]
      options.include = includes
    else
      for rel in req.query.include
        includes.push req.ModelClass.associations[rel]
      options.include = includes
  req.ModelClass.find options
  .then (model) ->
    req.model = model
    next()
    
  
module.exports = router

  
