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
