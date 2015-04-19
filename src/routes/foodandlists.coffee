# models
List = require '../models/list'
Foodstuff = require '../models/foodstuff'
# create CRUD operations for the model

createCRUD = (app, Model, name) ->
  # plural form
  pl = name + 's'

  # auth middleware to make sure a user is logged in
  makeSureLoggedIn = (req, res, next) ->
    if req.user
      next()
    else
      next
        error: "User isn't logged in."
        status: 403

  # get reference to all models that the user owns
  app.get '/' + pl, makeSureLoggedIn, (req, res) ->
    Model.find
      users: req.user.username
    , (err, models) ->
      if err
        res.send err: err.toString()
      else
        res.send data: models
      return
    return

  # add new item
  app.post '/' + pl, makeSureLoggedIn, (req, res) ->
    data = req.body
    data.users = [req.user.username]
    n = new Model data
    n.save (err) ->
      if err
        res.send err: err.toString()
      else
        res.send status: 'ok'
      return
    return

  # delete item
  app.delete '/' + pl + '/:name', makeSureLoggedIn, (req, res) ->
    Model.remove
      name: req.params.name
      users: req.user.username
    , (err) ->
      if err
        res.send err: err.toString()
      else
        res.send status: 'ok'
      return
    return

  # update item
  app.put '/' + pl + '/:name', makeSureLoggedIn, (req, res) ->
    Model.update
      name: req.params.name
      users: req.user.username
    , req.body, {}, (err, num, raw) ->
      if err
        res.send err: err.toString()
      else
        res.send
          status: 'ok'
          num: num
      return
    return
  return

module.exports = (app) ->
  # create CRUD resource for list
  createCRUD app, List, 'list'
  # create CRUD resource for foodstuff
  createCRUD app, Foodstuff, 'foodstuff'
  return
