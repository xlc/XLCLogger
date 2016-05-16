require 'expose?jQuery!jquery' # expose to window for angular to use
angular = require 'angular'

require 'mdi/scss/materialdesignicons.scss'

require 'angular-material/angular-material.scss'

require 'angular-ui-router.statehelper'
require 'ngstorage'

app = angular.module 'app', [
  require 'angular-material'
  require 'angular-ui-router'
  'ui.router.stateHelper'
  'ngStorage'
]

app.config ($locationProvider) ->
  $locationProvider.html5Mode(true)

module.exports = app
