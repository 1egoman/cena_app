###
 * cena_auth
 * https://github.com/1egoman/cena_app
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';

# foodstuff controller
@app.controller 'FsController', ($scope, $routeParams, FoodStuff, ShopService, Tag, $rootScope, $modal) ->
  root = $scope
  root.isData = false

  # get all tags
  Tag.query (tags) ->
    root.tags = tags

  # deal storage
  root.deals = []

  # place to store incoming list data
  root.newFs = {}

  # foodstuff drawer
  root.foodstuffhidden = true

  # get all foodstuffs, initially...
  FoodStuff.query (all) ->
    root.isData = true # no refresh spinner
    root.foodstuffs = all

  # add new foodstuff
  root.add = (fs) ->
    # format tags correctly
    fs.tags = fs.tags or (fs.pretags or "").split(' ')

    # make sure $ amount doesn't start with a $
    fs.price = fs.price.substr(1) if fs.price[0] is '$'

    # add and push item to backend resource
    foodstuff = new FoodStuff fs
    foodstuff.$save ->
      root.foodstuffs.push fs

  # delete a foodstuff
  root.remove = (fs) ->
    FoodStuff.remove _id: fs._id, ->
      root.foodstuffs = _.without root.foodstuffs, fs

  # update a foodstuff price / tags / other attribute
  root.update = (list, pretags="") ->
    # format tags
    list.tags = pretags.split ' ' if pretags.length

    # update list on backend
    FoodStuff.update list, ->
      # close modal
      $("#edit-foodstuff-#{list._id}").modal 'hide'

  # add the tag, and delimit it with spaces
  root.addTagToNewFoodstuff = (tag) ->
    root.newFs.pretags = (root.newFs.pretags or '') + ' ' + tag
    root.newFs.pretags = root.newFs.pretags.trim()
    $('input#fs-tags').focus()
    true

  # list fuzzy searching
  root.matchesSearchString = (list, filter) ->

    # if there's no filter, return true
    if !filter
      return true

    # make filter lowercase
    filter = filter.toLowerCase()

    # create a corpus of the important parts of each list item
    corpus = _.compact _.map([
      'name'
      'desc'
      'tags'
    ], (key) ->
      JSON.stringify list[key]
    ).join(' ').toLowerCase().split /[ ,\[\]"-]/gi

    # how many matching words are there between the corpus
    # and the filter string?
    score = _.intersection(corpus, filter.split(' ')).length
    score > 0


  #########
  # Deals #
  #########

  # combine all shop deals into one master array
  root.getDeals = ->
    # get all shop tags
    tags = _.filter(root.tags, (t) ->
      t.name.indexOf('shop-') != -1
    )
    _.each tags, (t) ->
      ShopService.doCache t.name.slice(5), (d) ->
        if d and d.deals
          dealsToAdd = _.map(d.deals, (e) ->
            e.shop = t.name.slice(5)
            e
          )
          root.deals = root.deals.concat(dealsToAdd)
        console.log root.deals

  root.getDeals()

  root.findDeals = (name) ->
    _.filter root.deals, (d) ->
      d.relatesTo.indexOf(name) != -1
