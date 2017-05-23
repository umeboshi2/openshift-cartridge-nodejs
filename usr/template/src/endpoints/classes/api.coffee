path = require('path')
express = require('express')
routeBuilder = require('express-routebuilder')
Endpoints = require('endpoints')
module.exports = new (Endpoints.Application)(
  searchPaths: [ path.join(__dirname, '..', 'modules') ]
  routeBuilder: (routes, prefix) ->
    routeBuilder express.Router(), routes, prefix
  Controller: Endpoints.Controller.extend(
    baseUrl: '/v1'
    store: Endpoints.Store.bookshelf
    format: Endpoints.Format.jsonapi
    validators: [ Endpoints.ValidateJsonSchema ]))
