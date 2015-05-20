# settings controller
@app.controller "TagsController", ($scope, $http) ->
  root = $scope
  root.user = {}

  # get all tags
  root.getTags = ->
    $http
      method: "get"
      url: "/settings/tags"
    .success (data) ->
      root.user.tags = data.tags
  root.getTags()

  # add a new tag
  root.addTag = (name, color) ->
    $http
      method: "post"
      url: "/settings/tag"
      data:
        name: name
        color: color
    .success (data) ->
      root.user.tags.push
        name: name
        color: color

  # remove a tag
  root.removeTag = (t) ->
    $http
      method: "delete"
      url: "/settings/tag/#{t.name}"
    .success (data) ->
      root.user.tags = _.without root.user.tags, t
