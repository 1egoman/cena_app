# preferences service
@app.factory 'PrefsService', ($http) ->
  tags: []

  getTags: (callback) ->
    $http
      method: 'get'
      url: '/settings/tags'
      cache: true
    .success (data) =>
      @tags = data.tags
      callback and callback @tags
