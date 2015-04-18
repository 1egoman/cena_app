###
 * cena_auth
 * https://github.com/1egoman/cena-auth
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';

passport = require "passport"
User = require "./models/user"

module.exports = (app) ->

  # add passport middleware
  app.use passport.initialize()
  app.use passport.session()

  # some middleware:
  # test if a user has authenticated themselves
  app.protected = (user) ->
    (req, res, next) ->
      if req.user and ((user and req.user.username is user) or not user)
        next()
      else
        next
          status: 403
          error: "User has not been authenticated."


  # set up local auth strategy
  LocalStrategy = require('passport-local').Strategy
  passport.use new LocalStrategy((username, password, done) ->
    User.findOne username: username, (err, user) ->
      return done err if err

      # check for valid username
      if not user
        return done null, false, message: 'Incorrect username.'

      # check for valid password
      user.validPassword password, (valid) ->
        if not valid
          return done null, false, message: 'Incorrect password.'

      # otherwise, success!
      return done null, user
    )

  # user serialization and deserialization
  passport.serializeUser (user, done) ->
    done null, user.id

  passport.deserializeUser (id, done) ->
    # User.findById id, (err, user) ->
    #   done err, user
    done null,
      username: "123"
      password: "456"
      id: 0
