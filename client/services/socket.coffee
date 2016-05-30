shortid = require 'shortid'

app.service 'Socket', ($rootScope) ->
  
  clients = {}

  socket = io('localhost:3000')
  socket.on 'connect', ->
    socket.emit 'register', {
      type: 'viewer'
      name: 'XLCLogger'
      session: shortid.generate()
    }

  socket.on 'register', (prop) ->
    _.set clients, "[#{prop.type}][#{prop.name}][#{prop.session}]", true
    $rootScope.$apply ->
      $rootScope.$broadcast 'Socket:register', prop

  socket.on 'unregister', (prop) ->
    _.set clients, "[#{prop.type}][#{prop.name}][#{prop.session}]", null
    $rootScope.$apply ->
      $rootScope.$broadcast 'Socket:unregister', prop

  socket.on 'message', (data) ->
    $rootScope.$apply ->
      $rootScope.$broadcast 'Socket:message', data

  {
    clients
  }



