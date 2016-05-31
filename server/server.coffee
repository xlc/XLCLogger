io = require('socket.io')()
_ = require 'lodash'

port = process.env.PORT || 3000

clients = {}

io.on 'connection', (socket) ->

  console.log 'connection'

  prop = {}
  socket.on 'register', (data) ->
    console.log 'register', data.type, data.name, data.session, typeof data.session
    return if prop.registered
    prop.registered = true
    _.assign prop, data

    _.each clients, (obj, type) ->
      _.each obj, (obj2, name) ->
        _.each obj2, (s, session) ->
          return unless s
          console.log 'sending registers', type, name, session
          socket.emit 'register', {
            type, name, session
          }
          
    socket.broadcast.emit 'register', data
    _.set clients, "['#{prop.type}']['#{prop.name}']['#{prop.session}']", socket

  socket.on 'disconnect', ->
    console.log 'disconnect', prop.type, prop.name, prop.session
    _.set clients, "['#{prop.type}']['#{prop.name}']['#{prop.session}']", null
    socket.broadcast.emit 'unregister', _.pick prop, ['type', 'name', 'session']

  socket.on 'message', (message) ->
    console.log 'message', prop.type, prop.name, prop.session, message
    socket.broadcast.emit 'message', {
      from: prop.name
      session: prop.session
      message
    }
  
io.listen port

console.log 'started on port', port
