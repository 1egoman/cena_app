# preferences service
@app.factory 'PrefsService', ($http) ->
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
