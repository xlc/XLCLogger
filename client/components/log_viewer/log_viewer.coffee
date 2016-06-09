app.directive 'logViewer', ($timeout) -> {
  templateUrl: require './log_viewer.jade'
  scope: {
    logs: '<'
  }
  link: ($scope, $element) ->
    $scope.$watchCollection 'logs', ->
      el = $element.find '.md-virtual-repeat-scroller'
      top = el[0].scrollTop
      height = el.height()
      if el[0].scrollTop + height >= el[0].scrollHeight
        $timeout ->
          el.scrollTop(el[0].scrollHeight)
}
