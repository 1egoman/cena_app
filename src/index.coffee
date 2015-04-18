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
flash = require "flash"

# connect to database
require("./db") "mongodb://cena:cena@ds061611.mongolab.com:61611/cena_auth"

# passport middleware
app.use require("express-session")
  secret: 'keyboard cat',
  resave: true,
  saveUninitialized: false
app.use require("body-parser").urlencoded(extended: true)
app.use flash()

require("./auth_setup") app
require("./auth_routes") app

app.get "/auth", app.protected(), (req, res) ->
  res.send "yay"

app.get '/', (req, res) ->
  res.render "index", user: JSON.stringify req.user


# error handling middleware
app.use (err, req, res, next) ->
  console.error err
  res.status err.status
  res.send err.error

port = process.env.PORT or 8000
app.listen port, () ->
  console.log "-> :#{port}"
