###
 * cena_auth
 * https://github.com/1egoman/cena-auth
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';

app = (require "express")()
app.set "view engine", "ejs"
passport = require "passport"

# passport middleware
app.use require("express-session")
  secret: 'keyboard cat',
  resave: true,
  saveUninitialized: false
app.use require("body-parser").urlencoded(extended: true)

app.use passport.initialize()
app.use passport.session()

# make sure that a user has authenticated.
isAuthenticated = (user) ->
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
  done null,
    username: username
    password: password
    id: 0
  # done true
  # User.findOne username: username, (err, user) ->
  #   return done err if err
  #
  #   if !user
  #     done null, false, message: 'Incorrect username.'
  #   else if !user.validPassword(password)
  #     done null, false, message: 'Incorrect password.'
  #   else
  #     done null, user
  )

# user serialization
passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  # User.findById id, (err, user) ->
  #   done err, user
  done null,
    username: "123"
    password: "456"
    id: 0

# login view
app.get "/login", (req, res) ->
  res.render "login_dialog"

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

app.get "/auth", isAuthenticated(), (req, res) ->
  res.send "yay"

app.get '/',
  # passport.authenticate('local',
  #   successRedirect: '/',
  #   failureRedirect: '/login'
  # ),
  (req, res) ->
    res.render "index", user: JSON.stringify req.user


# error handling middleware
app.use (err, req, res, next) ->
  console.error err
  res.status err.status
  res.send err.error

app.listen process.env.PORT or 8000
