# auth middleware to make sure a user is logged in
module.exports = (req, res, next) ->
  if req.user
    next()
  else
    next
      error: "User isn't logged in."
      status: 403
