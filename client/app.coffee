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

# app.run ->
#   log = require 'applog'
  
#   log 1
#   log 'str'
#   log new Date
#   log {a:1}
#   log.debug 'debug'
#   log.log 'log'
#   log.info 'info'
#   log.warn 'warn'
#   log.error 'error'

#   test_log = log.scope 'test'
#   test_log 'test'
#   test_log.debug 'debug'
#   test_log.log 'log'
#   test_log.info 'info'
#   test_log.warn 'warn'
#   test_log.error 'error'

#   t2_log = test_log.scope 'nested'
#   t2_log 'nested'
#   t2_log.debug 'debug'
#   t2_log.log 'log'
#   t2_log.info 'info'
#   t2_log.warn 'warn'
#   t2_log.error 'error'

#   console.log 1
#   console.log 'str'
#   console.log new Date
#   console.log {a:1}
#   console.debug 'debug'
#   console.log 'log'
#   console.info 'info'
#   console.warn 'warn'
#   console.error 'error'

#   setInterval ->
#     log new Date
#   , 10

module.exports = app
