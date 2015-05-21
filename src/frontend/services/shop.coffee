# shop service
@app.factory 'ShopService', ($http) ->
  cache: {}
  gettingCache: []
  getMatchesFor: (item, shop, callback) ->

    cont = ->
      callback _.filter(cache[shop] or [], (i) ->
        i.relatedTo.indexOf(item) != -1
      )
      return

    console.log @cache, shop
    if !@cache[shop]
      that = this
      @doCache shop, ->
        console.log that.cache
        return
    # else {
    #  cont();
    #}
    return
  doCache: (shop, callback) ->
    that = this
    # so you can't call this function constantly and overlaod the server
    if @gettingCache.indexOf(shop) != -1
      return
    @gettingCache.push shop
    $http(
      method: 'get'
      url: '/shops/' + shop + '/deals.json').success (data) ->
      that.cache[shop] = data
      callback and callback(data)
      return
    return
