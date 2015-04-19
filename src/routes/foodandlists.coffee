# models
List = require '../models/list'
Foodstuff = require '../models/foodstuff'
# create CRUD operations for the model

createCRUD = (app, Model, name) ->
  # plural form
  pl = name + 's'
  # get reference to all models
  app.get '/' + pl, (req, res) ->
    Model.find {}, (err, models) ->
      if err
        res.send err: err.toString()
      else
        res.send data: models
      return
    return
  # add new item
  app.post '/' + pl, (req, res) ->
    data = req.body
    data.user = 'admin'
    n = new Model(data)
    n.save (err) ->
      if err
        res.send err: err.toString()
      else
        res.send status: 'ok'
      return
    return
  # delete item
  app.delete '/' + pl + '/:name', (req, res) ->
    Model.remove { name: req.params.name }, (err) ->
      if err
        res.send err: err.toString()
      else
        res.send status: 'ok'
      return
    return
  # update item
  app.put '/' + pl + '/:name', (req, res) ->
    Model.update { name: req.params.name }, req.body, {}, (err, num, raw) ->
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
