moment = require 'moment'

app.service 'LogStore', () ->

  _all_logs = []

  add_log = (data) ->
    data.text = _.map data.message.message, (m) ->
      if _.isString m
        m
      else
        JSON.stringify m
    .join ' '
    data.timestampText = moment(data.message.timestamp).format 'MM-DD HH:mm:ss.SSS'
    data.scopeText = data.message.scope.join ':'
    _all_logs.push data
    data

  {
    add_log
    get_all: -> _all_logs
    clear: -> _all_logs = []
  }
