# list factory
@app.factory 'ListService', ($http) ->
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
