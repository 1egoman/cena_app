###
 * cena_auth
 * https://github.com/1egoman/cena_app
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';

# list controller
@app.controller 'ListController', ($scope, $routeParams, List, FoodStuff, Tag, Shop, $rootScope, $location) ->
  root = $scope
  root.isData = false

  # get all tags
  Tag.query (tags) ->
    root.tags = tags

  # place to store incoming list data
  root.newList = pretags: $routeParams.type or ''
  root.printableList = {}

  # search string for list
  root.listSearchString = ''

  # get all lists
  List.query (all) ->
    root.lists = all
    root.isData = true

    # get lists to display
    root.DispLists = _.filter root.lists, (list) ->
      list.name is $routeParams.list

    # if we got nothing, display all
    if root.DispLists.length is 0
      root.DispLists = all

    # next, the foodstuffs
    FoodStuff.query (all) ->
      root.foodstuffs = all

    root.doPrintableList()

  # return all lists that have the specified tag included
  root.getListsByTag = (lists, tag) ->
    # if tag is set, look for everything with that tag (grocery and recipe)
    # otherwise, get everthing that isn't a tag (other)
    out = _.filter lists, (l) ->
      if tag
        l.tags.indexOf(tag) isnt -1
      else
        l.tags.indexOf('grocery') is -1 and l.tags.indexOf('recipe') is -1

    # if it's a grocery list, with hopefully a date in the name
    if tag is 'grocery'
      # sort all grocery lists
      out = _.sortBy out, (n) ->
        # find dates by regex
        dates = n.name.match(/[\d]{1,2}[\.\/-]?[\d]{1,2}[\.\/-]?[\d]{2,4}?/gi)
        if dates and dates.length

          # format the regex output into a date,
          # and get the timestamp to compare
          preDate = dates[0].split(/[\.\/-]/gi)
          if preDate.length < 1
            preDate = dates[0].match(/[.]{2}/gi)
          new Date(preDate.join('/')).getTime()

      .reverse()
    out

  # list fuzzy searching
  root.matchesSearchString = (list, filter) ->
    # if there's no filter, return true
    if !filter
      return true
    # make filter lowercase
    filter = filter.toLowerCase()
    # create a corpus of the important parts of each list item
    corpus = _.compact(_.map([
      'name'
      'desc'
      'tags'
    ], (key) ->
      JSON.stringify list[key]
    ).join(' ').toLowerCase().split(/[ ,\[\]"-]/gi))
    # how many matching words are there between the corpus
    # and the filter string?
    score = _.intersection(corpus, filter.split(' ')).length
    # console.log(list.name, score);
    # console.log(corpus, filter.split(' '))
    score > 0

  # add new list
  root.add = (listData, opts={}) ->
    # format tags correctly
    listData.tags = listData.tags or (listData.pretags or "").split ' '

    # add and push item to backend resource
    list = new List listData
    list.$save ->
      root.lists.push listData
      $location.url "/lists" if opts.redirect

  # delete list
  root.remove = (list) ->
    List.remove _id: list._id, ->

      # remove from both the lists, and the current displayed lists as well.
      root.lists = _.without.apply(_, [root.lists].concat _.where(root.lists, list))
      root.DispLists = _.without.apply(_, [root.DispLists].concat _.where(root.DispLists, list))

  # update list
  root.update = (list) ->
    List.update list

  # add a new item to list
  root.addToList = (list, item) ->

    # find the item we want
    listItem = _.find root.getTypeahead(list), (s) ->
      s.name is item

    # make sure these are set
    listItem.price = listItem.price or '0.00' if not listItem.contents
    listItem.amt = listItem.amt or 1
    listItem.checked = false

    # add to list
    list.contents.push $.extend(true, {}, listItem)
    List.update list, ->

      # regenerate printable lists
      root.doPrintableList()

  # delete a new item from list
  root.removeFromList = (list, item) ->
    # find the item we want
    listItem = _.find root.getTypeahead(list), (s) ->
      s.name is item

    # remove item from list
    list.contents = _.without list.contents, _.find(list.contents, (i) -> i._id is listItem._id)
    List.update list, ->

      # regenerate printable lists
      root.doPrintableList()

  # update user access model after saving
  root.updateUsersModal = (list) ->
    List.update list
    $('.accessModal').modal 'hide'
    true

  # get items for typeahead (box used to add new list items)
  root.getTypeahead = (list) ->
    _.union \
      root.foodstuffs,
      _.filter root.lists, (lst) ->
        lst.name isnt list.name

  # get totals from list
  # right now, only does price (subtotal) and
  # real price (including tax)
  root.totalList = (list, tax=0.08) ->
    totalPrice = _.reduce list.contents, (prev, l) ->
      if l.contents
        prev + l.amt * root.totalList(l).subtotal
      else
        prev + l.amt * parseFloat l.price
    , 0

    subtotal: totalPrice
    price: totalPrice * (1+tax)
    tax: tax

  # extract all items from a list
  # and turn it into 1 big list
  # (a flatten operation for nested lists)
  root.deItemizeList = (list) ->
    _.flatten _.map list.contents, (l) ->
      if l.contents
        root.deItemizeList l
      else
        l

  # sort by the "sort-" tags into groups
  # (this is part of the printable list sorting)
  root.sortByTag = (list) ->
    # flatten the list
    flatList = root.deItemizeList list

    # sort the list
    _.groupBy flatList, (n) ->
      # sort by sort tags that are present
      _.filter n.tags, (t) ->
        t.indexOf('sort-') is 0
      .join(' ') or 'Unsorted'

  # generate the printable list
  root.doPrintableList = ->
    _.each root.lists, (l) ->
      root.printableList[l.name] = root.sortByTag(l)

  # add the tag, and delimit it with spaces
  # this is ued in the new list dialog to make
  # those "quick tag add" buttons.
  root.addTagToNewList = (tag) ->
    root.newList.pretags = (root.newList.pretags or '') + ' ' + tag
    root.newList.pretags = root.newList.pretags.trim()
    $('input#list-tags').focus()
    true

  # grant a new user access to the specified list
  root.addUserToList = (l, user) ->
    root.lists[l].users.push user

  # remove a user's access to the specified list
  root.removeUserFromList = (l, user) ->
    root.lists[l].users = _.without root.lists[l].users, user
    return


  #########
  # Shops #
  #########

  # get all possible "shop" tags
  root.getShops = ->
    _.filter root.tags, (t) ->
      t.name.indexOf('shop-') is 0

  # add/delete shops for a specified list and item
  root.addRemoveShop = (list, cnt, s) ->

    # first, remove all shop tags.
    cnt.tags = cnt.tags.filter (t) ->
      t.indexOf('shop-') isnt 0

    # then, add our new tag
    cnt.tags.push s if s

    # update
    List.update list

  # given a list item, retrive the shop
  # that the list item will be bought at.
  root.getShopForList = (cnt) ->
    allShops = root.getShops()
    shop = _.find cnt.tags, (t) ->
      t.indexOf('shop-') is 0

    _.find allShops, (s) ->
      s.name is shop


  #############
  # Utilities #
  #############

  # convert any string into a safe css classname
  # from http://stackoverflow.com/questions/7627000/javascript-convert-string-to-safe-class-name-for-css
  root.safeClassName = (name) ->
    name.replace /[^a-z0-9]/g, (s) ->
      c = s.charCodeAt 0
      return '-' if c is 32
      return '_' + s.toLowerCase() if c >= 65 and c <= 90
      return '__' + ('000' + c.toString(16)).slice -4


  # update all list instances
  $rootScope.$on 'listUpdate', (status, data) ->
    root.lists = data
    # get lists to display
    root.DispLists = _.filter(root.lists, (list) ->
      list.name == $routeParams.list
    )
    # if we got nothing, display all
    if root.DispLists.length == 0
      root.DispLists = data
    # update printable list
    root.doPrintableList()
    return
  # update all foodstuff instances
  $rootScope.$on 'fsUpdate', (status, data) ->
    root.foodstuffs = data
    return
  return
