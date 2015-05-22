# list factory
@app.factory 'List', ($http, $resource) ->
  return $resource "/lists/:id", id: '@_id',
    update:
      method: "put"

  # get all lists for a specified user
  get: (cb) ->
    # see if we are trying to get lists for the current user or another
    user = _.last(location.pathname.split('/')).replace('/', '') or ''
    $http
      method: 'get'
      url: '/lists/' + user
      cache: true
    .success (data) ->
      cb and cb data.data

  # add a new list to the logged in user
  add: (list, cb) ->
    $http
      method: 'post'
      url: '/lists'
      data: angular.toJson(list)
      cache: true
    .success (data) ->
      cb and cb data

  # remove a list from the logged in user
  remove: (list, cb) ->
    $http
      method: 'delete'
      url: '/lists/' + list.name
      data: angular.toJson(list)
      cache: true
    .success (data) ->
      cb and cb data

  # update a list
  update: (list, cb) ->
    $http
      method: 'put'
      url: '/lists/' + list.name
      data: angular.toJson(list)
      cache: true
    .success (data) ->
      cb and cb data
