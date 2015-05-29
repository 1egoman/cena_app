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
  root.add = (t) ->
    tag = new Tag t

    tag.$save (err) ->
      # inherit $ methods ($delete, $save, etc)
      t.__proto__ = tag.__proto__
      root.tags.push t

  # remove a tag
  root.remove = (t) ->
    # delete all tags from database
    _.filter root.tags, (tag) ->
      if tag.name is t.name
        tag.$delete()

    # delete tags locally
    root.tags = _.without.apply(_, [root.tags].concat _.where(root.tags, t))
