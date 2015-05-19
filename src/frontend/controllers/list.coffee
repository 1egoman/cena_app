# list controller 
@app.controller 'ListController', ($scope, $routeParams, ListService, FoodStuffService, PrefsService, $rootScope, $location) ->
  root = $scope
  root.isData = false
  # get all the tags that have been set in user preferences
  PrefsService.getTags (tags) ->
    root.userTags = tags
    return
  # place to store incoming list data
  root.newList = pretags: $routeParams.type or ''
  root.printableList = {}
  # search string for list
  root.listSearchString = ''
  ListService.get (all) ->
    root.lists = all
    root.isData = true
    # get lists to display
    root.DispLists = _.filter(root.lists, (list) ->
      list.name == $routeParams.list
    )
    # if we got nothing, display all
    if root.DispLists.length == 0
      root.DispLists = all
    # next, the foodstuffs
    # root.foodstuffs = [
    #   {
    #     name: "Bread",
    #     price: 5.50,
    #     tags: ["abc"]
    #   },
    #   {
    #     name: "Milk",
    #     price: 1.00,
    #     tags: ["abc"]
    #   },
    #   {
    #     name: "Cheese",
    #     price: 0.24,
    #     tags: ["abc"]
    #   }
    # ];
    FoodStuffService.get (all) ->
      root.foodstuffs = all
      return
    root.doPrintableList()
    return
  # return all lists that have the specified tag included

  root.getListsByTag = (lists, tag) ->
    # if tag is set, look for everything with that tag
    # otherwise, get everthing that isn't a tag
    out = _.filter(lists, (l) ->
      if tag
        l.tags.indexOf(tag) != -1
      else
        l.tags.indexOf('grocery') == -1 and l.tags.indexOf('recipe') == -1
    )
    # if it's a grocery list, with hopefully a date in the name
    if tag == 'grocery'
      # sort all grocery lists
      out = _.sortBy(out, (n) ->
        # find dates by regex
        dates = n.name.match(/[\d]{1,2}[\.\/-]?[\d]{1,2}[\.\/-]?[\d]{2,4}?/gi)
        if dates and dates.length
          # format the regex output into a date,
          # and get the timestamp to compare
          preDate = dates[0].split(/[\.\/-]/gi)
          if preDate.length < 1
            preDate = dates[0].match(/[.]{2}/gi)
          return new Date(preDate.join('/')).getTime()
        return
      ).reverse()
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

  root.addList = (list) ->
    # tags
    list.tags = list.tags or list.pretags and list.pretags.split(' ')
    ListService.add list, (data) ->
      # update all list instances
      ListService.get (all) ->
        $rootScope.$emit 'listUpdate', all
        $location.url '/lists'
        return
      return
    return

  # delete list

  root.delList = (list) ->
    ListService.remove { name: list.name }, (data) ->
      # update all list instances
      ListService.get (all) ->
        root.lists = data
        $rootScope.$emit 'listUpdate', all
        return
      return
    return

  # add a new item to list

  root.addToList = (list, item) ->
    _.each _.filter(root.lists, (l) ->
      l.name == list.name
    ), (list) ->
      # find the item we want
      fs = _.filter(root.getTypeahead(list), (s) ->
        s.name == item
      )
      # update each list
      _.each fs, (f) ->
        # make sure these are set
        if !f.contents
          f.price = f.price or '0.00'
        f.amt = f.amt or 1
        f.checked = false
        # add to list
        list.contents.push $.extend(true, {}, f)
        return
      # lastly, update the backend
      ListService.update list
      return
    return

  # delete a new item from list

  root.delFromList = (list, item) ->
    _.each _.filter(root.lists, (l) ->
      l.name == list.name
    ), (list) ->
      # find the foodstuff we want
      fs = _.filter(list.contents, (s) ->
        s.name == item
      )
      # update each list
      _.each fs, (f) ->
        list.contents.splice list.contents.indexOf(f), 1
        return
      # lastly, update the backend
      ListService.update list
      return
    return

  # force a list update

  root.updateList = (list) ->
    ListService.update list
    return

  root.updateUsersModal = (list) ->
    ListService.update list
    $('.accessModal').modal 'hide'
    return

  # get items for typeahead

  root.getTypeahead = (list) ->
    _.union root.foodstuffs, _.filter(root.lists, (lst) ->
      lst.name != list.name
    )

  # get total stuff about list

  root.totalList = (list) ->
    totalPrice = _.reduce(list.contents, ((prev, l) ->
      if l.contents
        prev + l.amt * root.totalList(l).price
      else
        prev + l.amt * parseFloat(l.price)
    ), 0)
    { price: totalPrice }

  # extract all items from a list
  # and turn it into 1 big list

  root.deItemizeList = (list) ->
    _.flatten _.map(list.contents, (l) ->
      if l.contents
        root.deItemizeList l
      else
        l
    )

  root.sortByTag = (list) ->
    # flatten the list
    flatList = root.deItemizeList(list)
    # sort the list
    _.groupBy flatList, (n) ->
      # sort by sort tags that are present
      _.filter(n.tags, (t) ->
        t.indexOf('sort-') == 0
      ).join(' ') or 'Unsorted'

  root.doPrintableList = ->
    _.each root.lists, (l) ->
      root.printableList[l.name] = root.sortByTag(l)
      # console.log(root.printableList);
      return
    return

  # add the tag, and delimit it with spaces

  root.addTagToNewList = (tag) ->
    root.newList.pretags = (root.newList.pretags or '') + ' ' + tag
    root.newList.pretags = root.newList.pretags.trim()
    $('input#list-tags').focus()
    return

  # grant a new user access to the specified list

  root.addUserToList = (l, user) ->
    root.lists[l].users.push user
    console.log 'ADD', root.lists[l].users, l
    return

  # remove a user's access to the specified list

  root.removeUserFromList = (l, user) ->
    root.lists[l].users = _.without(root.lists[l].users, user)
    return

  # get all possible "shop" tags

  root.getShops = ->
    _.filter root.userTags, (t) ->
      t.name.indexOf('shop-') == 0

  # add/delete shops for a specified list and item

  root.addRemoveShop = (l, cnt, s) ->
    # first, remove all shop tags.
    cnt.tags = cnt.tags.filter((t) ->
      t.indexOf('shop-') != 0
    )
    # then, add our new tag
    if s
      cnt.tags.push s
    # update
    root.updateList l
    return

  # given a list item, reterive the shop
  # that the list item will be bought at.

  root.getShopForList = (cnt) ->
    allShops = root.getShops()
    shop = _.find(cnt.tags, (t) ->
      t.indexOf('shop-') == 0
    )
    _.find allShops, (s) ->
      s.name == shop

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
