###
 * cena_app
 * https://github.com/1egoman/cena_app
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';
makeSureLoggedIn = require "./userloggedin"
matchWithItems = require "../scrapers/matchItems"

module.exports = (app) ->

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
    try
      shop = require "../scrapers/"+req.params.shop
    catch
      res.send
        status: "error"
        message: "No such shop #{req.params.shop}."
    finally
      if shop.scrape
        shop.scrape null, (err, data) ->
          if err
            res.send
              status: "error"
              message: err
          else
            matchWithItems req.user, data, (err, deals) ->
              if err
                res.send
                  status: "error"
                  message: err
              else
                res.send deals: deals
      else
        res.send deals: []
