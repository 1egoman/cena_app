# home controller
@app.controller 'ShopsController', ($scope, Shop, Tag) ->
  root = $scope

  # Hardcoded shops
  # TODO un half-ass this solution...
  Tag.query (tags) ->
    Shop.query (shops) ->
      root.shops = _.map shops, (shop) ->

        # enabled: is the user currently using this shop?
        shop.enabled = _.filter(tags, (t) -> t.name is shop.tag.name).length
        shop

      # root.shops = [
      #   name: "Aldi"
      #   tag:
      #     name: "shop-aldi"
      #     color: "#001E78"
      #   enabled: _.filter(tags, (t) -> t.name is "shop-aldi").length
      # ,
      #   name: "Wegmans"
      #   tag:
      #     name: "shop-weg"
      #     color: "#9b3835"
      #   enabled: _.filter(tags, (t) -> t.name is "shop-weg").length
      # ,
      #   name: "Market 32"
      #   tag:
      #     name: "shop-m32"
      #     color: "#63bd4a"
      #   enabled: _.filter(tags, (t) -> t.name is "shop-m32").length
      # ]

  # select a shop, and set it to be active / inactive
  root.selectShop = (shop, enabled=true, add, remove) ->
    shop.enabled = enabled

    # add the tag / remove the corresponding tag
    if enabled
      add shop.tag.name, shop.tag.color
    else
      remove shop.tag
