shortid = require 'shortid'

sequence = 0

create_logger = (socket, scope = []) ->

  _log = (level, args...) ->
    if scope.length
      console[level] scope.join('|'), args...
    else
      console[level] args...
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
      innerScope ?= shortid.generate()
      create_logger socket, scope.concat innerScope
  }

module.exports = (server, name, session) ->
  socket = io(server)
  socket.on 'connect', ->
    socket.emit 'register', {
      type: 'logger'
      name: name
      session: session ? shortid.generate()
    }

  create_logger socket
