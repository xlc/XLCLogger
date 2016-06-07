window.log = require('./xlclogger')({
  server: 'localhost:3000'
  name: 'XLCLogger'
  no_console: true
  override_console: true
})
module.exports = window.log
