# tags service
app.factory "TagService", ($http) ->

  callOnChange: []
  cache: []

  # call on new tag add/delete
  onChange: (fire) ->
    @callOnChange.push fire

  # get all tags
  get: (callback) ->
    $http
      method: "get"
      url: "/settings/tags"
    .success (data) =>
      @cache = data.tags

      f(@cache) for f in @callOnChange
      callback null, @cache

  # add a new tag
  add: (name, color, callback) ->
    $http
      method: "post"
      url: "/settings/tag"
      data:
        name: name
        color: color
    .success (data) =>
      @cache.push
        name: name
        color: color

      f(@cache) for f in @callOnChange
      callback and callback null

  # remove a tag
  remove: (t, callback) ->
    $http
      method: "delete"
      url: "/settings/tag/#{t.name}"
    .success (data) =>
      # remove all instances from cache
      @cache = _.without.apply(_, [@cache].concat _.where(@cache, t))

      f(@cache) for f in @callOnChange
      callback and callback()
