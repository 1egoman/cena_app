###
 * cena_auth
 * https://github.com/1egoman/cena_app
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';

# tags service
@app.factory "Tag", ($http, $resource) ->
  $resource "/settings/tags/:name",
    name: '@name'
