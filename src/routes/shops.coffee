###
 * cena_app
 * https://github.com/1egoman/cena_app
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';
fs = require "fs"
path = require "path"
chalk = require "chalk"
_ = require "underscore"
async = require "async"

makeSureLoggedIn = require "./userloggedin"
matchWithItems = require "../scrapers/matchItems"

Shop = require "../models/shop"

# how long are deals good, in seconds?
dealsExpireAfter = 60 * 60 * 1000; # 1 hour in milliseconds

module.exports = (app) ->

  # get all shops
  app.get "/shops", makeSureLoggedIn, (req, res) ->
    Shop.find {}, (err, shops) ->
      if err
        res.send error: err
      else
        async.map shops, (shop, cb) ->
          fs.exists path.join(__dirname, "../scrapers", shop.internalName), (exists) ->
            shop.scraper = exists
            cb null, shop
        , (err, shops) ->
          res.send shops

  # shop info
  app.get "/shops/:shop.json", makeSureLoggedIn, (req, res) ->
    try
      shop = require "../scrapers/"+req.params.shop
    catch
      res.send
        status: "error"
        message: "No such shop #{req.params.shop}."
    finally
      res.send shop.info()

  # scraper for a shop's deals
  app.get "/shops/:shop/deals.json", makeSureLoggedIn, (req, res) ->

    # calculate deals for a store
    calculate = (shopName, res) ->
      console.log chalk.cyan "----> Calculating #{shopName} deals..."

      try
        shop = require "../scrapers/"+shopName
      catch
        res.send
          status: "error"
          message: "No such shop #{shopName}."
      finally
        if not shop then return
        if shop.scrape
          shop.scrape null, (err, data) ->
            if err
              res.send
                status: "error"
                message: err
            else
              matchWithItems req.user, data, (err, deals) ->

                # cache the deals
                cache = JSON.stringify
                  name: shopName
                  date: new Date
                  deals: deals
                , null, 2
                fs.writeFile "src/scrapers/"+shopName+"/deals.json", cache, (err) ->
                  err and console.log "Error in writing scraper cache for #{shopName}: #{err}"


                if err
                  res.send
                    status: "error"
                    message: err
                else
                  # filter out all the crud from scraping
                  deals = deals.filter (d) -> d.name.length
                  res.send deals: deals
        else
          res.send deals: []

    # first, try and read deals from disk
    fs.readFile path.join("src", "scrapers", req.params.shop, "deals.json"), (err, data) ->
      if not err and json and json.length
        json = JSON.parse data
        if new Date(json.date).getTime() + dealsExpireAfter > new Date().getTime()
          res.send deals: json.deals
        else
          calculate req.params.shop, res
      else
        calculate req.params.shop, res
