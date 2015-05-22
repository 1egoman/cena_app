# home controller
@app.controller 'ShopsController', ($scope, Tag) ->
  root = $scope

  # Hardcoded shops
  # TODO un half-ass this solution...
  Tag.query (tags) ->
    root.shops = [
      name: "Aldi"
      tag:
        name: "shop-aldi"
        color: "#001E78"
      enabled: _.filter(tags, (t) -> t.name is "shop-aldi").length
    ,
      name: "Wegmans"
      tag:
        name: "shop-weg"
        color: "#459940"
      enabled: _.filter(tags, (t) -> t.name is "shop-weg").length
    ,
      name: "Price Chopper"
      tag:
        name: "shop-pc"
        color: "#EE3A43"
      enabled: _.filter(tags, (t) -> t.name is "shop-pc").length
    ]

  # select a shop, and set it to be active / inactive
  root.selectShop = (shop, enabled=true, add, remove) ->
    shop.enabled = enabled

    # add the tag / remove the corresponding tag
    if enabled
      add shop.tag.name, shop.tag.color
    else
      remove shop.tag
