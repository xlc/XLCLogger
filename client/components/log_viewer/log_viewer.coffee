app.component 'logViewer', {
  templateUrl: require './log_viewer.jade'
  bindings: {
    logs: '<'
  }
  controller: ($scope) ->

}
