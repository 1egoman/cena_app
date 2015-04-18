###
 * cena_auth
 * https://github.com/1egoman/cena-auth
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';

passport = require "passport"

module.exports = (app) ->

  # login view
  app.get "/login", (req, res) ->
    res.render "login_dialog", flash_msg: res.locals.flash

  # login post route
  app.post '/auth/user', passport.authenticate('local',
    successRedirect: '/'
    failureRedirect: '/login'
    failureFlash: true
  )

  # logout route
  app.get '/logout', (req, res) ->
    req.logout()
    res.redirect '/'
