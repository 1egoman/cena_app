###
user.coffee
This model represents the users that connect to and access cena.
###

mongoose = require 'mongoose'

# create schema
user = mongoose.Schema
  username: String
  hashedPassword: String

# check for a valid password
user.methods.validPassword = (password, callback) ->
  this.model('User').find hashedPass: password, (err, v) ->
    callback not err or v

# export the module
module.exports = mongoose.model 'User', user
