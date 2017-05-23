path = require 'path'
thisFolderName = __dirname.split(path.sep).pop()
API = require '../../classes/api'
module.exports = new API.Controller
  model: require './model'
  basePath: thisFolderName
