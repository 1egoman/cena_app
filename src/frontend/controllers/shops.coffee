# shops controller
@app.controller 'ShopsController', ($scope, Shop, Tag) ->
  root = $scope

  root.shopPage = 0


  # Get all shops
  Tag.query (tags) ->
    Shop.query (shops) ->
      root.shops = _.map shops, (shop) ->

        # enabled: is the user currently using this shop?
        shop.enabled = _.filter(tags, (t) -> t.name is shop.tag.name).length
        shop

      root.displayShops = root.shops

  # select a shop, and set it to be active / inactive
  root.selectShop = (shop, enabled=true, add, remove) ->
    shop.enabled = enabled

    # add the tag / remove the corresponding tag
    if enabled
      add shop.tag.name, shop.tag.color
    else
      remove shop.tag

  # apply needle through a search of all list items
  root.applySearchNeedle = (needle, haystack=root.shops) ->
    needle = needle.toLowerCase()

    if needle.length is 0

      # no search needle, so we display all
      root.displayShops = root.shops

    else

      if needle.indexOf(' ') isnt -1

        # sort by the amount of similar words
        # the store has in common with the needle
        root.displayShops = _.sortBy haystack, (entry) ->
          _.intersection(entry.name.toLowerCase().split(' '), needle.split(' ')).length

      else

        # sort by the amount of similar characters
        # the store has in common with the needle
        root.displayShops = _.sortBy haystack, (entry) ->
          _.intersection(entry.name.toLowerCase().split(''), needle.split('')).length

      # reverse the sort order
      root.displayShops = root.displayShops.reverse()


    # select the shop page
    root.displayShops = root.displayShops[root.shopPage*10...(root.shopPage+1)*10]
    root.displayShops = root.shops[0...10] if root.displayShops.length is 0
