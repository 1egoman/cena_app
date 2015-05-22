# models
List = require "../models/list"
Foodstuff = require "../models/foodstuff"
# create CRUD operations for the model

# auth middleware to make sure a user is logged in
makeSureLoggedIn = require "./userloggedin"


createCRUD = (app, Model, name) ->
  # plural form
  pl = name + "s"

  # get reference to all models that the specified user owns
  app.get "/#{pl}", makeSureLoggedIn, (req, res) ->
    Model.find
      users: req.query.user or req.user.username
    , (err, models) ->
      if err
        res.send err: err.toString()
      else
        res.send models

  # get reference to one model that matches the query and the specified user owns
  app.get "/#{pl}/:id?", makeSureLoggedIn, (req, res) ->
    Model.findOne
      _id: req.params.id or req.query.id or req.query._id
      users: req.query.user or req.user.username
    , (err, model) ->
      if err
        res.send err: err.toString()
      else
        res.send model

  # add new item
  app.post "/#{pl}", makeSureLoggedIn, (req, res) ->
    data = req.body
    data.users = [req.user.username]

    # make sure name doesn't have slashes in it, otherwise weird routing things
    # will hapen on the frontend.
    data.name = (data.name or "untitled").replace /\//g, '-'

    # create and save
    n = new Model data
    n.save (err) ->
      if err
        res.send err: err.toString()
      else
        res.send status: "ok"
      return
    return

  # delete item
  app.delete "/#{pl}/:id?", makeSureLoggedIn, (req, res) ->
    Model.remove
      _id: req.params.id or req.query.id or req.query._id
      users: req.query.user or req.user.username
    , (err) ->
      if err
        res.send err: err.toString()
      else
        res.send status: "ok"

      return
    return

  # update item
  app.put "/#{pl}/:id?", makeSureLoggedIn, (req, res, next) ->

    # make sure a user hasn't removed their own
    # permisssion to view the list, or remove the "first owner" of the list
    if (
      req.body and
      req.user.username in req.body.users
    )
      Model.update
        _id: req.params.id or req.query.id or req.query._id
        users: req.query.user or req.user.username
      , req.body, {}, (err, num, raw) ->
        if err
          res.send err: err.toString()
        else
          res.send
            status: "ok"
            num: num
    else
      next
        error: "User cannot remove access to their own list, or remove the primary owner of the list."
        status: 403

module.exports = (app) ->
  # create CRUD resource for list
  createCRUD app, List, "list"
  # create CRUD resource for foodstuff
  createCRUD app, Foodstuff, "foodstuff"
  return
