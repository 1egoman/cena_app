###
 * cena_auth
 * https://github.com/1egoman/cena_app
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';

# foodstuff factory
@app.factory 'FoodStuff', ($http, $resource) ->
  $resource "/foodstuffs/:id", id: '@_id',
    update:
      method: "put"
