# foodstuff factory
@app.factory 'FoodStuffService', ($http) ->
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
