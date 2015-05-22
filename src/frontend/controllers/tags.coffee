# settings controller
@app.controller "TagsController", ($scope, $http, Tag) ->
  root = $scope

  # user list
  root.tags = []

  # get all tags
  root.get = ->
    Tag.query (tags) ->
      root.tags = tags
  root.get()

  # add a new tag
  root.add = (name, color) ->
    tag = new Tag
      name: name
      color: color

    tag.$save (err) ->
      root.tags.push
        name: name
        color: color

  # remove a tag
  root.remove = (t) ->
    Tag.remove t, (err) ->
      root.tags = _.without.apply(_, [root.tags].concat _.where(root.tags, t))
