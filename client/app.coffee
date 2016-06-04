require 'expose?jQuery!jquery' # expose to window for angular to use
window.$ = window.jQuery
angular = require 'angular'

require 'mdi/scss/materialdesignicons.scss'
require 'roboto-fontface'

require 'angular-material/angular-material.scss'

require 'angular-ui-router.statehelper'
require 'ngstorage'
require 'angular-ui-indeterminate'

app = angular.module 'app', [
  require 'angular-material'
  require 'angular-ui-router'
  'ui.router.stateHelper'
  'ngStorage'
  'ui.indeterminate'
]

app.config ($locationProvider) ->
  $locationProvider.html5Mode(true)

module.exports = app
