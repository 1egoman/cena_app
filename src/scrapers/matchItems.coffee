Foodstuff = require '../models/foodstuff'
_ = require "underscore"
Lev = require "levenshtein"

# how close together items need to be to be "related"
RELATION_COEFFICIENT = process.env.RELATION_COEFFICIENT or 6


###
Ok, so this is how this works:

Each iteration, take foodstuffname and shift it over one. So:
  foodstuffname: "abc"
  storename: "super fancy abc"
Then:
  0. Distance between
     "abc" and
     "super fancy abc"
  1. Distance between
     " abc" and
     "super fancy abc"
  2. Distance between
     "  abc" and
     "super fancy abc"
  3. Distance between
     "   abc" and
     "super fancy abc"
  4. Distance between
     "    abc" and
     "super fancy abc"
  (and so on, until)
  12. Distance between
     "            abc" and
     "super fancy abc"

Getting distance:
  Think of the levenshtein distance function, only all three costs decrease
  exponentially as the iteration count increases. So:
  > score += <cost here> * (fsname.length-i)
  This means that no matter the "prefix" or "suffix" on a storename (branding,
  or other promotional material), we will always return the best case senario, aka
  where the 2 strings match up best.

  turn on debug below if confused, and run something like:
  > console.log relate "fresh family pack chicken breasts", "chicken breast"
###
relate = (storename, foodstuffname, add=1, del=1, replace=1) ->
  debug = false

  # offset foodstuffname by storename
  scores = [0...Math.abs(foodstuffname.length-storename.length-1)].map (s) ->
    debug and console.log s, "--------------------"
    score = 0

    # generate "spaced" string
    spaces = [0...s].map(-> ' ').join ''
    fsname = spaces + foodstuffname

    # log out both names
    debug and console.log fsname
    debug and console.log storename

    # get distance
    for i in [0..fsname.length]
      if storename.length < i
        score += add * (fsname.length-i)
      else if fsname.length < i
        score += del * (fsname.length-i)
      # replacing spaces don't cost anything
      else if fsname[i] is ' '
      else if fsname[i] isnt storename[i]
        score += replace * (fsname.length-i)

    # log out score
    debug and console.log score
    score

  _.min scores

module.exports = (user, items, cb) ->

  # get all foodstuffs
  Foodstuff.find users: user.username, (err, fs) ->
    cb null, items.map (i) ->

      i.relatesTo = _.compact fs.map (fd) ->

        # do the items relate?
        distance = relate i.name, fd.name
        if distance < RELATION_COEFFICIENT
          fd.name

      i
