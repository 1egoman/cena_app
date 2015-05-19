# angular routing
@app.config [
  '$routeProvider'
  ($routeProvider) ->
    $routeProvider

      .when '/dash',
        templateUrl: '/partials/home.html'
        controller: 'HomeController'

      .when '/lists',
        templateUrl: '/partials/lists.html'
        controller: 'ListController'
      .when '/lists/:list',
        templateUrl: '/partials/lists.html'
        controller: 'ListController'
      .when '/addlist',
        templateUrl: '/partials/addlist.html'
        controller: 'ListController'
      .when '/addlist/:type',
        templateUrl: '/partials/addlist.html'
        controller: 'ListController'

      .when '/foodstuffs',
        templateUrl: '/partials/foodstuff.html'
        controller: 'ListController'
      .when '/foodstuffs/:list',
        templateUrl: '/partials/lists.html'
        controller: 'ListController'
      .when '/addfoodstuff',
        templateUrl: '/partials/addlist.html'
        controller: 'ListController'

      .when '/settings',
        templateUrl: '/partials/settings.html'

      .when '/readme',
          templateUrl: '/partials/readme.html'

      .otherwise redirectTo: '/lists'

]
