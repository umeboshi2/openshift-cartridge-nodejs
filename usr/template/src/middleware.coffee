

bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
expressSession = require 'express-session'
morgan = require 'morgan'
httpsRedirect = require 'express-https-redirect'

env = process.env.NODE_ENV or 'development'

setup = (app) ->
  # logging
  app.use morgan 'combined'

  # parsing
  app.use cookieParser()
  app.use bodyParser.json limit: '10mb'
  app.use bodyParser.urlencoded({ extended: true })

  # session handling
  app.use expressSession
    secret: 'please set me from outside config'
    resave: false
    saveUninitialized: false

  # redirect to https
  #if '__DEV__' of process.env and process.env.__DEV__ is 'true'
  if env is 'development'
    console.log 'skipping httpsRedirect'
  else
    app.use '/', httpsRedirect()

    
  
module.exports =
  setup: setup
  
