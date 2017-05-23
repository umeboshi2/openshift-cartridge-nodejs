fs = require('fs')
path = require('path')
express = require('express')

bodyParser = require('body-parser')
routeBuilder = require('express-routebuilder')
cors = require('cors')
modulePath = path.join(__dirname, 'modules')
resources = fs.readdirSync(modulePath)

router = express.Router()

API = require('./classes/api')

router.use cors()
router.use bodyParser.urlencoded extended: true
router.use bodyParser.json
  type: [
    'application/json'
    'application/vnd.api+json'
    ]


resources.forEach (resource) ->
  API.register resource
  router.use API.endpoint resource
  return

router.get '/v1', (req, res) ->
  res.set 'Content-Type', 'application/json'
  res.send JSON.stringify(API.index(), null, 2)
  return

router.get '/', (req, res) ->
  res.redirect '/v1'
  return

module.exports = router
