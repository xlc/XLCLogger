log = require 'applog'
moment = require 'moment'

app.config (stateHelperProvider) ->
  stateHelperProvider
    .state
      name: 'main'
      url: '/'
      template: '<app-main></app-main>'

app.component 'appMain', {
  templateUrl: require './app_main.jade'
  controller: ($scope, Socket) ->

    _all_logs = []
    _logs = []
    _filters = {}

    update_logs = ->
      _logs = _.filter _all_logs, (data) ->
        _filters[data.from]?.sessions?[data.session]?.value &&
          _.find _logLevels, {name: data.message.level}
          ?.value &&
          $scope.format(data).match new RegExp $scope.filter_text

    create_app = (data) ->
      return unless data.type == 'logger'
      if !_filters[data.name]
        _filters[data.name] = {
          sessions: {}
          value: true
          is_indeterminate: ->
            _ @sessions
              .map 'value'
              .uniq()
              .value()
              .length == 2
          update_value: ->
            _.each @sessions, (s) =>
              s.value = @value
              return
            update_logs()
        }
      _filters[data.name].sessions[data.session] = {
        value: true
        update_value: ->
          _filters[data.name].value = @value
          update_logs()
      }

    _.each Socket.clients.logger, (app, name) ->
      _.each app, (session, name) ->
        create_app {
          type: 'logger'
          name: app
          session
        }

    _logLevels = ['debug', 'log', 'info', 'warn', 'error'].map (level) ->
      {
        name: level
        value: true
        update_value: update_logs
      }

    $scope.$on 'Socket:register', (evt, data) ->
      create_app data

    $scope.$on 'Socket:unregister', (evt, data) ->
      if _filters[data.name]
        delete _filters[data.name][data.sessions]
      if _.keys(_filters[data.name]).length == 0
        delete _filters[data.name]

    $scope.$on 'Socket:message', (evt, data) ->
      _all_logs.push data
      if _.get _filters, "[#{data.from}].sessions[#{data.session}].value"
        _logs.push data

    $scope.$watch 'filter_text', update_logs

    log 1
    log 'str'
    log new Date
    log {a:1}
    log.debug 'debug'
    log.log 'log'
    log.info 'info'
    log.warn 'warn'
    log.error 'error'

    test_log = log.scope 'test'
    test_log 'test'
    test_log.debug 'debug'
    test_log.log 'log'
    test_log.info 'info'
    test_log.warn 'warn'
    test_log.error 'error'

    t2_log = test_log.scope 'nested'
    t2_log 'nested'
    t2_log.debug 'debug'
    t2_log.log 'log'
    t2_log.info 'info'
    t2_log.warn 'warn'
    t2_log.error 'error'

    $scope.format = (msg) ->
      _.map msg.message.message, (m) ->
        if _.isString m
          m
        else
          JSON.stringify m
      .join ' '

    $scope.formatTime = (time) ->
      moment(time).format 'MM-DD HH:mm:ss.SSS'

    $scope.formatScope = (scope) ->
      scope.join ':'

    {
      filters: -> _filters
      logs: -> _logs
      logLevels: -> _logLevels
    }
}

