# home controller
@app.controller 'ShopsController', ($scope, Tag) ->
  root = $scope

  # Hardcoded shops
  # TODO Pipe this into the api...
  root.shops = [
    name: "Aldi"
    tag:
      name: "shop-aldi"
      color: "#001E78"
    enabled: false
  ,
    name: "Wegmans"
    tag:
      name: "shop-weg"
      color: "#459940"
    enabled: false
  ]

  # select a shop, and set it to be active / inactive
  root.selectShop = (shop, enabled=true, add, remove) ->
    shop.enabled = enabled

    # add the tag / remove the corresponding tag
    if enabled
      add shop.tag.name, shop.tag.color
    else
      remove shop.tag
