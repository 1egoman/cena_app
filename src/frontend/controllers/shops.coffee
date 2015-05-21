# home controller
@app.controller 'ShopsController', ($scope, TagService) ->
  root = $scope

  root.shops = [
    name: "Aldi"
    tag:
      name: "shop-aldi"
      color: "danger"
    enabled: true
  ,
    name: "Wegmans"
    tag:
      name: "shop-weg"
      color: "danger"
    enabled: false
  ]

  # select a shop, and set it to be active / inactive
  root.selectShop = (shop, enabled=true) ->
    shop.enabled = enabled

    # add the tag / remove the corresponding tag
    if enabled
      TagService.add shop.tag.name, shop.tag.color
    else
      TagService.remove shop.tag
