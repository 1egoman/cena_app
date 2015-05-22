###
 * cena_auth
 * https://github.com/1egoman/cena_app
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
'use strict';

# nav controller
@app.controller 'NavController', ($scope) ->

  # get the user whose lists we are viewing currently
  $scope.owner = _.last(location.pathname.split('/')).replace '/', ''
