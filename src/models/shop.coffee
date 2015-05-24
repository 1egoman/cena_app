###
shop.coffee
This model represents the shops that users can buy goods at.
###

mongoose = require 'mongoose'

# create schema
shop = mongoose.Schema
  name: String
  internalName: String
  desc: String

  tag:
    name: String
    color: String

  

# export the module
module.exports = mongoose.model 'Shop', shop
