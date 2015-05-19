# settings controller
@app.controller 'SettingsController', ($scope, $http) ->
  root = $scope
  root.user = {}
  # gt all tags

  root.getTags = ->
    $http(
      method: 'get'
      url: '/settings/tags').success (data) ->
      root.user.tags = data.tags
      return
    return

  root.getTags()
  # add a new tag

  root.addTag = (name) ->
    $http(
      method: 'post'
      url: '/settings/tag'
      data: name: name).success (data) ->
      root.user.tags.push
        name: name
        color: 'danger'
      return
    return

  # remove tag

  root.removeTag = (t) ->
    $http(
      method: 'delete'
      url: '/settings/tag/' + t.name).success (data) ->
      console.log root.user.tags
      root.user.tags = _.without(root.user.tags, t)
      return
    return

  return
