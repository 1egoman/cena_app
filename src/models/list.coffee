mongoose = require('mongoose')

listSchema = mongoose.Schema
  name: String
  desc: String
  tags: Array
  contents: Array
  user: String
module.exports = mongoose.model 'List', listSchema
