# log = require 'applog'

app.config (stateHelperProvider) ->
  stateHelperProvider
    .state
      name: 'main'
      url: '/'
      template: '<app-main></app-main>'

app.component 'appMain', {
  templateUrl: require './app_main.jade'
  controller: ($scope, $timeout, Socket, LogStore, $localStorage) ->

    _logs = []
    _filters = {}
    _exlcude_filters = []

    save = ->
      $localStorage.exclude_filters = _.map _exlcude_filters, (f) -> _.pick f, ['text', 'enabled']

    load = ->
      _exlcude_filters = _.map $localStorage.exclude_filters, ({text, enabled}) ->
        {
          text
          enabled
          regex: new RegExp text
        }

    load()

    clear_all = ->
      _logs = []
      LogStore.clear()

    include_data = (data) ->
      return false unless _filters[data.from]?.sessions?[data.session]?.value
      return false unless _.find(_logLevels, {name: data.message.level})?.value
      if $scope.filter_text
        return false unless data.text.match new RegExp $scope.filter_text
      if $scope.scope_filter_text
        return false unless data.scopeText.match new RegExp $scope.scope_filter_text
      return false if _.some _exlcude_filters, (filter) ->
        filter.enabled && data.text.match filter.regex
      true

    update_logs = ->
      _logs = _.filter LogStore.get_all(), include_data

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

    add_exclude_filter = (text) ->
      _exlcude_filters.push {
        text
        regex: new RegExp text
        enabled: true
      }
      save()
      update_logs()

    update_exclude_filter = (filter, idx) ->
      if filter.text.length == 0
        _exlcude_filters.splice idx, 1
      else
        filter.regex = new RegExp filter.text
      save()
      update_logs()

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
      data = LogStore.add_log data
      if include_data data
        _logs.push data
      el = $ '.log-viewer > div'
      top = el[0].scrollTop
      height = el.height()
      if el[0].scrollTop + height >= el[0].scrollHeight
        $timeout ->
          el.scrollTop(el[0].scrollHeight)

    # log 1
    # log 'str'
    # log new Date
    # log {a:1}
    # log.debug 'debug'
    # log.log 'log'
    # log.info 'info'
    # log.warn 'warn'
    # log.error 'error'

    # test_log = log.scope 'test'
    # test_log 'test'
    # test_log.debug 'debug'
    # test_log.log 'log'
    # test_log.info 'info'
    # test_log.warn 'warn'
    # test_log.error 'error'

    # t2_log = test_log.scope 'nested'
    # t2_log 'nested'
    # t2_log.debug 'debug'
    # t2_log.log 'log'
    # t2_log.info 'info'
    # t2_log.warn 'warn'
    # t2_log.error 'error'

    # setInterval ->
    #   log new Date
    # , 10

    {
      filters: -> _filters
      logs: -> _logs
      logLevels: -> _logLevels
      exclude_filters: -> _exlcude_filters
      update_logs
      clear_all
      add_exclude_filter
      update_exclude_filter
      save
    }
}

