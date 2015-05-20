# home controller
@app.controller 'ShopsController', ($scope) ->
  root = $scope

  root.shops = [
    name: "Aldi"
    tag: "shop-aldi"
    enabled: true
  ,
    name: "Wegmans"
    tag: "shop-weg"
    enabled: false
  ]
