sequence = 0

original_console = window.console

create_logger = (options) ->
  socket = options.socket
  scope = options.scope
  if !scope?
    scope = []

  _log = (level, args...) ->
    if !options.connected || !options.no_console
      # restore console before logging
      # otherwise may cause conflict with other logger that overrides console
      current_console = window.console
      window.console = original_console
      if scope.length
        console[level] scope.join('|'), args...
      else
        console[level] args...
      window.console = current_console
    if socket
      socket.emit 'message', {
        level
        scope
        id: ++sequence
        timestampe: new Date
        message: args
      }
    return

  log = _log.bind null, 'log'

  _.assign log, {
    debug: _log.bind null, 'debug'
    log: _log.bind null, 'log'
    info: _log.bind null, 'info'
    warn: _log.bind null, 'warn'
    error: _log.bind null, 'error'
    scope: (innerScope) ->
      innerScope ?= Math.random().toString(36).substr(2, 5)
      new_options = Object.create options
      new_options.override_console = false
      new_options.scope = scope.concat(innerScope)
      create_logger new_options
  }

  if options.override_console
    new_console = Object.create original_console
    window.console = new_console
    _.assign new_console, {
      debug: log.debug
      log: log.log
      info: log.info
      warn: log.warn
      error: log.error
    }

  log

module.exports = (options = {}) ->
  if options.server && process.env.NODE_ENV != 'production'
    io = require 'socket.io-client'

    socket = io options.server
    options.connected = false
    socket.on 'connect', ->
      options.connected = true
      socket.emit 'register', {
        type: 'logger'
        name: options.name || 'app'
        session: options.session ? new Date().toISOString()
      }
    options.socket = socket

  create_logger options
