###
 * cena_auth
 * https://github.com/1egoman/cena_app
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';

# list factory
@app.factory 'List', ($http, $resource) ->
  $resource "/lists/:id", id: '@_id',
    update:
      method: "put"
