# settings controller
@app.controller "TagsController", ($scope, $http, TagService) ->
  root = $scope

  # user list
  root.tags = []

  # new tag added or deleted
  TagService.onChange (tags) ->
    root.tags = tags

  # get all tags
  root.getTags = ->
    TagService.get (err, tags) ->
      root.tags = tags
  root.getTags()

  # add a new tag
  root.addTag = (name, color) ->
    TagService.add name, color, (err, tags) ->
      root.tags.push
        name: name
        color: color

  # remove a tag
  root.removeTag = (t) ->
    TagService.remove t, (err) ->
      root.tags = _.without root.tags, t
