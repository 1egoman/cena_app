# nav controller
@app.controller 'NavController', ($scope) ->
  # get the user whoose lists we are viewing currently
  $scope.owner = _.last(location.pathname.split('/')).replace('/', '')
