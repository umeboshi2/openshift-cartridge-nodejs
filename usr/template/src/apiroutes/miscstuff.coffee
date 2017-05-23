fs = require 'fs'
path = require 'path'

_ = require 'underscore'
Promise = require 'bluebird'
express = require 'express'

router = express.Router()


multer = require 'multer'
upload = multer
  dest: 'uploads/'

{ get_models } = require './common'


ReadMes = require('../../readmes.json').readmes
rmap = {}
for r in ReadMes
  rmap[r.id] = r.content
  


#router.use hasUserAuth

router.get '/all-models', (req, res) ->
  get_models req, res
  .then ->
    res.json res.locals.models

router.post '/upload-photos', upload.array('zathras', 12), (req, res) ->
  console.log req.files
  res.app.locals.sql.models.uploads.bulkCreate req.files
  .then ->
    res.json
      result: 'success'
      data: req.files


router.get '/readmes', (req, res) ->
  res.json ReadMes

router.get '/readmes/:id', (req, res) ->
  filename = rmap[req.params.id]
  #filename = req.params[0]
  filename = path.resolve '../ghub/repos', filename
  data = fs.readFileSync(filename, 'utf8')
  res.json
    filename: rmap[req.params.id]
    content: data
    
  
module.exports = router
