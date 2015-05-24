###
 * cena_auth
 * https://github.com/1egoman/cena_app
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';

# require all routes
module.exports = (app) ->
  require("./foodandlists").index app
  require("./auth") app
  require("./shops") app
  require("./tags") app
