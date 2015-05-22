###
 * cena_auth
 * https://github.com/1egoman/cena_app
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';

app = (require "express")()
app.set "view engine", "ejs"
passport = require "passport"
flash = require "flash"
path = require "path"
bodyParser = require "body-parser"
expressSession = require "express-session"
RedisStore = require('connect-redis')(expressSession)

# connect to database
require("./db") process.env.DB or "mongodb://cena:cena@ds031661.mongolab.com:31661/cenav2"

# middleware
app.use expressSession
  secret: 'keyboard cat',
  resave: true,
  saveUninitialized: false,
  store: new RedisStore
    host: "greeneye.redistogo.com"
    port: 10449
    pass: "40b1b3e4e5a6ddd492e33905b1c67d34"
app.use bodyParser.json()
app.use flash()

# auto compile and serve sass stylesheets
# app.use require("sass-middleware") src: "public", quiet: true

node_sass = require "node-sass-middleware"
app.use node_sass
  src: path.join(__dirname, "../public"),
  dest: path.join(__dirname, "../public"),
  # debug: true
app.use require("express-static") path.join(__dirname, '../public')

# set up authentication service
require("./auth_setup") app

# set up main app routes
require("./routes") app


app.get "/auth", app.protected(), (req, res) ->
  res.send "yay"

app.get '/', (req, res) ->
  res.render "index", user: req.user

# main app route
app.get "/account", (req, res) ->
  if req.user
    res.redirect "/account/#{req.user.username}"
  else
    # not authorized
    res.redirect "/#"

# go to a user's lists
app.get "/account/:user", (req, res) ->
  if req.user and req.params.user is req.user.username
    # my lists
    res.render "main", user: req.user, loadUser: req.user.username
  else if req.user
    # other's lists
    res.render "main", user: req.user, loadUser: req.params.user
  else
    # not authorized
    res.redirect "/#"

# error handling middleware
app.use (err, req, res, next) ->
  console.error err
  res.status err.status
  res.send err.error

port = process.env.PORT or 8000
app.listen port, () ->
  console.log "-> :#{port}"
