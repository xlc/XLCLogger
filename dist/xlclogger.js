// Generated by CoffeeScript 1.10.0
(function() {
  var create_logger, original_console, sequence,
    slice = [].slice;

  sequence = 0;

  original_console = window.console;

  create_logger = function(options) {
    var _log, log, new_console, scope, socket;
    socket = options.socket;
    scope = options.scope;
    if (scope == null) {
      scope = [];
    }
    _log = function() {
      var args, current_console, level;
      level = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      if (!options.connected || !options.no_console) {
        current_console = window.console;
        window.console = original_console;
        if (scope.length) {
          console[level].apply(console, [scope.join('|')].concat(slice.call(args)));
        } else {
          console[level].apply(console, args);
        }
        window.console = current_console;
      }
      if (socket) {
        socket.emit('message', {
          level: level,
          scope: scope,
          id: ++sequence,
          timestampe: new Date,
          message: args
        });
      }
    };
    log = _log.bind(null, 'log');
    _.assign(log, {
      debug: _log.bind(null, 'debug'),
      log: _log.bind(null, 'log'),
      info: _log.bind(null, 'info'),
      warn: _log.bind(null, 'warn'),
      error: _log.bind(null, 'error'),
      scope: function(innerScope) {
        var new_options;
        if (innerScope == null) {
          innerScope = Math.random().toString(36).substr(2, 5);
        }
        new_options = Object.create(options);
        new_options.override_console = false;
        new_options.scope = scope.concat(innerScope);
        return create_logger(new_options);
      }
    });
    if (options.override_console) {
      new_console = Object.create(original_console);
      window.console = new_console;
      _.assign(new_console, {
        debug: log.debug,
        log: log.log,
        info: log.info,
        warn: log.warn,
        error: log.error
      });
    }
    return log;
  };

  module.exports = function(options) {
    var io, socket;
    if (options == null) {
      options = {};
    }
    if (options.server && process.env.NODE_ENV !== 'production') {
      io = require('socket.io-client');
      socket = io(options.server);
      options.connected = false;
      socket.on('connect', function() {
        var ref;
        options.connected = true;
        return socket.emit('register', {
          type: 'logger',
          name: options.name || 'app',
          session: (ref = options.session) != null ? ref : new Date().toISOString()
        });
      });
      options.socket = socket;
    }
    return create_logger(options);
  };

}).call(this);
