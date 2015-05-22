###
 * cena_auth
 * https://github.com/1egoman/cena_app
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';

# shop service
@app.factory 'ShopService', ($http) ->
  cache: {}
  gettingCache: []

  # get all matching deals for a specified shop and deal combo
  getMatchesFor: (item, shop, callback) ->

    cont = ->
      callback _.filter(cache[shop] or [], (i) ->
        i.relatedTo.indexOf(item) != -1
      )

    # console.log @cache, shop
    if !@cache[shop]
      @doCache shop, =>
        # console.log that.cache


  doCache: (shop, callback) ->
    # so you can't call this function constantly and overlaod the server
    if @gettingCache.indexOf(shop) != -1
      return
    @gettingCache.push shop

    $http
      method: 'get'
      url: '/shops/' + shop + '/deals.json'
      cache: true
    .success (data) =>
      @cache[shop] = data
      callback and callback data
