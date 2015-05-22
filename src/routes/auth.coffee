###
 * cena_auth
 * https://github.com/1egoman/cena_app
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';

passport = require "passport"
bodyParser = require "body-parser"

User = require '../models/user'

module.exports = (app) ->

  # login view
  app.get "/login", (req, res) ->
    res.render "login_dialog", flash_msg: res.locals.flash

  # login post route
  app.post '/auth/user',
    bodyParser.urlencoded(extended: true),
    passport.authenticate 'local',
      successRedirect: '/account'
      failureRedirect: '/login'
      failureFlash: true

  # logout route
  app.get '/logout', (req, res) ->
    req.logout()
    res.redirect '/'

  # == settings ==

  # all possible tag colors
  tagColors = [
    "danger"
    "primary"
    "success"
  ]

  # add new tag
  app.post '/settings/tags/:name?', (req, res) ->
    console.log req.params.name
    if req.user
      User.update
        username: req.user.username
      ,
        $push:
          tags:
            # update user with new tag
            name: req.params.name or req.body.name,
            color: do ->
              if req.body.color
                req.body.color
              else
                # generate random color to match with this item
                i = Math.floor(Math.random() * (tagColors.length+1))
                i = 0 if i > tagColors.length-1
                tagColors[i]

      , {}, (err, num, raw) ->
        if err
          res.send err: err.toString()
        else
          res.send
            status: 'ok'
            num: num
    else
      res.send error: "User isn't logged in."

  # delete tag
  app.delete '/settings/tags/:name?', (req, res) ->
    if req.user
      User.update
        username: req.user.username
      ,
        $pull:
          tags:
            name: req.body.name or req.params.name
      , {}, (err, num, raw) ->
        if err
          res.send err: err.toString()
        else
          res.send
            status: 'ok'
            num: num
    else
      res.send error: "User isn't logged in."

  # get tag list
  app.get '/settings/tags', (req, res) ->
    if req.user
      User.findOne
        username: req.user.username
      , (err, user) ->
        if err
          res.send err: err.toString()
        else
          res.send user.tags
    else
      res.send error: "User isn't logged in."
