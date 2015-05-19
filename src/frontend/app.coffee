@app = angular.module('Cena', [
  'ui.bootstrap'
  'ngRoute'
  'hc.marked'
])


@app.factory 'ListService', ($http) ->
  {
    get: (cb) ->
      # see if we are trying to get lists for the current user or another
      user = _.last(location.pathname.split('/')).replace('/', '') or ''
      $http(
        method: 'get'
        url: '/lists/' + user).success (data) ->
        cb and cb(data.data)
        return
      return
    add: (list, cb) ->
      $http(
        method: 'post'
        url: '/lists'
        data: angular.toJson(list)).success (data) ->
        cb and cb(data)
        return
      return
    remove: (list, cb) ->
      $http(
        method: 'delete'
        url: '/lists/' + list.name
        data: angular.toJson(list)).success (data) ->
        cb and cb(data)
        return
      return
    update: (list, cb) ->
      $http(
        method: 'put'
        url: '/lists/' + list.name
        data: angular.toJson(list)).success (data) ->
        cb and cb(data)
        return
      return

  }
@app.controller 'FsController', ($scope, $routeParams, FoodStuffService, ShopService, PrefsService, $rootScope, $modal) ->
  root = $scope
  root.isData = false
  # deal storage
  root.deals = []
  # place to store incoming list data
  root.newFs = {}
  # foodstuff drawer
  root.foodstuffhidden = true
  FoodStuffService.get (all) ->
    root.foodstuffs = all
    root.isData = true
    return
  # add new list

  root.addFs = (fs) ->
    # tags
    fs.tags = fs.tags or fs.pretags.split(' ')
    # make sure $ amount doesn't start with a $
    if fs.price[0] == '$'
      fs.price = fs.price.substr(1)
    FoodStuffService.add fs, (data) ->
      # update all foodstuff instances
      FoodStuffService.get (all) ->
        root.newFs = {}
        $rootScope.$emit 'fsUpdate', all
        return
      return
    return

  # add new list

  root.delFs = (fs) ->
    FoodStuffService.remove { name: fs.name }, (data) ->
      # update all foodstuff instances
      FoodStuffService.get (all) ->
        $rootScope.$emit 'fsUpdate', all
        return
      return
    return

  # update a foodstuff price / tags

  root.modifyFs = (list, pretags) ->
    list.tags = pretags.split(' ')
    # format tags
    root.updateFs list
    # update list on backend
    $('#edit-foodstuff-' + list._id).modal 'hide'
    # close modal
    return

  # force a list update

  root.updateFs = (list) ->
    FoodStuffService.update list
    return

  # update all list instances
  $rootScope.$on 'fsUpdate', (status, data) ->
    root.foodstuffs = data
    return
  # add the tag, and delimit it with spaces

  root.addTagToNewFoodstuff = (tag) ->
    root.newFs.pretags = (root.newFs.pretags or '') + ' ' + tag
    root.newFs.pretags = root.newFs.pretags.trim()
    $('input#fs-tags').focus()
    return

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

  # combine all shop deals into one master array

  root.getDeals = ->
    # get all shop tags
    tags = _.filter(PrefsService.tags, (t) ->
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
        return
      return
    return

  root.getDeals()

  root.findDeals = (name) ->
    _.filter root.deals, (d) ->
      d.relatesTo.indexOf(name) != -1

  return
@app.factory 'FoodStuffService', ($http) ->
  {
    get: (cb) ->
      $http(
        method: 'get'
        url: '/foodstuffs').success (data) ->
        cb and cb(data.data)
        return
      return
    add: (list, cb) ->
      $http(
        method: 'post'
        url: '/foodstuffs'
        data: angular.toJson(list)).success (data) ->
        cb and cb(data)
        return
      return
    remove: (list, cb) ->
      $http(
        method: 'delete'
        url: '/foodstuffs/' + list.name
        data: angular.toJson(list)).success (data) ->
        cb and cb(data)
        return
      return
    update: (list, cb) ->
      $http(
        method: 'put'
        url: '/foodstuffs/' + list.name
        data: angular.toJson(list)).success (data) ->
        cb and cb(data)
        return
      return

  }
@app.factory 'PrefsService', ($http) ->
  {
    tags: []
    getTags: (callback) ->
      root = this
      $http(
        method: 'get'
        url: '/settings/tags').success (data) ->
        root.tags = data.tags
        callback and callback(root.tags)
        return
      return

  }
@app.controller 'NavController', ($scope) ->
  # get the user whoose lists we are viewing currently
  $scope.owner = _.last(location.pathname.split('/')).replace('/', '')
  return
@app.factory 'ShopService', ($http) ->
  {
    cache: {}
    gettingCache: []
    getMatchesFor: (item, shop, callback) ->

      cont = ->
        callback _.filter(cache[shop] or [], (i) ->
          i.relatedTo.indexOf(item) != -1
        )
        return

      console.log @cache, shop
      if !@cache[shop]
        that = this
        @doCache shop, ->
          console.log that.cache
          return
      # else {
      #  cont();
      #}
      return
    doCache: (shop, callback) ->
      that = this
      # so you can't call this function constantly and overlaod the server
      if @gettingCache.indexOf(shop) != -1
        return
      @gettingCache.push shop
      $http(
        method: 'get'
        url: '/shops/' + shop + '/deals.json').success (data) ->
        that.cache[shop] = data
        callback and callback(data)
        return
      return

  }
@app.controller 'SettingsController', ($scope, $http) ->
  root = $scope
  root.user = {}
  # gt all tags

  root.getTags = ->
    $http(
      method: 'get'
      url: '/settings/tags').success (data) ->
      root.user.tags = data.tags
      return
    return

  root.getTags()
  # add a new tag

  root.addTag = (name) ->
    $http(
      method: 'post'
      url: '/settings/tag'
      data: name: name).success (data) ->
      root.user.tags.push
        name: name
        color: 'danger'
      return
    return

  # remove tag

  root.removeTag = (t) ->
    $http(
      method: 'delete'
      url: '/settings/tag/' + t.name).success (data) ->
      console.log root.user.tags
      root.user.tags = _.without(root.user.tags, t)
      return
    return

  return

# ---
# generated by js2coffee 2.0.4
