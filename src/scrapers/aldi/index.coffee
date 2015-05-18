cheerio = require "cheerio"
request = require "request"
async = require "async"
_ = require "underscore"

# turn the crap jquery returns into a usable response
# I know, it's a dirty hack
makeArray = (obj) ->
  _.compact Object.keys(obj).map (key) ->
    if parseInt key
      obj[key]

exports.info = ->
  name: "Aldi"
  tag: "shop-aldi"

exports.scrape = (opts={storeid: 2623397}, cb) ->
  # send a request to all urls
  async.map [
    "http://weeklyads.aldi.us/Aldi/BrowseByPage/Index/?StoreID=#{opts.storeid}&PromotionCode=Aldi-150520INS&PromotionViewMode=1"
    "http://weeklyads.aldi.us/Aldi/BrowseByListing/ByAllListings/?StoreID=#{opts.storeid}#PageNumber=1"
  ], (url, cb) ->
    request
      method: "GET"
      url: url
    , (error, resp, body) ->
      cb error or null, body
  , (error, results) ->
    return cb error if error

    output = _.flatten results.map (page) ->
      # load markup into cheerio
      $ = cheerio.load page

      deals = $(".gridpage > div").map (i, e) ->
        at = $(this)

        # id for the item
        id: at.attr("data-listingid")

        # the name of the item
        # filter out the extended description, and remove branding
        name: do ->
          n = at.find(".title").text().trim().toLowerCase().split "\r\n"
          if n.length
            n[0].replace("kirkwood", '').trim()
          else
            n.trim()

        # an image representation of the item
        img: at.find("img").attr "src"

        # the items price
        price: do ->
          price = at.find(".deal").text()

          # sort out the cents issue
          if price.charCodeAt(price.length-1) is 162
            price = "0.#{price[..1]}"

          price

        # the url of the item
        url: "http://weeklyads.aldi.us/Aldi/ListingDetail?ispartial=N&ReturnCircularPageFlag=Y&StoreID=#{opts.storeid}&ListingID=#{at.attr("data-listingid")}"

      makeArray deals

    cb null, output
