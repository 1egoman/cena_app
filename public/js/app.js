(function() {
  this.app = angular.module('Cena', ['ui.bootstrap', 'ngRoute', 'hc.marked']);

  this.app.factory('ListService', function($http) {
    return {
      get: function(cb) {
        var user;
        user = _.last(location.pathname.split('/')).replace('/', '') || '';
        $http({
          method: 'get',
          url: '/lists/' + user
        }).success(function(data) {
          cb && cb(data.data);
        });
      },
      add: function(list, cb) {
        $http({
          method: 'post',
          url: '/lists',
          data: angular.toJson(list)
        }).success(function(data) {
          cb && cb(data);
        });
      },
      remove: function(list, cb) {
        $http({
          method: 'delete',
          url: '/lists/' + list.name,
          data: angular.toJson(list)
        }).success(function(data) {
          cb && cb(data);
        });
      },
      update: function(list, cb) {
        $http({
          method: 'put',
          url: '/lists/' + list.name,
          data: angular.toJson(list)
        }).success(function(data) {
          cb && cb(data);
        });
      }
    };
  });

  this.app.controller('FsController', function($scope, $routeParams, FoodStuffService, ShopService, PrefsService, $rootScope, $modal) {
    var root;
    root = $scope;
    root.isData = false;
    root.deals = [];
    root.newFs = {};
    root.foodstuffhidden = true;
    FoodStuffService.get(function(all) {
      root.foodstuffs = all;
      root.isData = true;
    });
    root.addFs = function(fs) {
      fs.tags = fs.tags || fs.pretags.split(' ');
      if (fs.price[0] === '$') {
        fs.price = fs.price.substr(1);
      }
      FoodStuffService.add(fs, function(data) {
        FoodStuffService.get(function(all) {
          root.newFs = {};
          $rootScope.$emit('fsUpdate', all);
        });
      });
    };
    root.delFs = function(fs) {
      FoodStuffService.remove({
        name: fs.name
      }, function(data) {
        FoodStuffService.get(function(all) {
          $rootScope.$emit('fsUpdate', all);
        });
      });
    };
    root.modifyFs = function(list, pretags) {
      list.tags = pretags.split(' ');
      root.updateFs(list);
      $('#edit-foodstuff-' + list._id).modal('hide');
    };
    root.updateFs = function(list) {
      FoodStuffService.update(list);
    };
    $rootScope.$on('fsUpdate', function(status, data) {
      root.foodstuffs = data;
    });
    root.addTagToNewFoodstuff = function(tag) {
      root.newFs.pretags = (root.newFs.pretags || '') + ' ' + tag;
      root.newFs.pretags = root.newFs.pretags.trim();
      $('input#fs-tags').focus();
    };
    root.matchesSearchString = function(list, filter) {
      var corpus, score;
      if (!filter) {
        return true;
      }
      filter = filter.toLowerCase();
      corpus = _.compact(_.map(['name', 'desc', 'tags'], function(key) {
        return JSON.stringify(list[key]);
      }).join(' ').toLowerCase().split(/[ ,\[\]"-]/gi));
      score = _.intersection(corpus, filter.split(' ')).length;
      return score > 0;
    };
    root.getDeals = function() {
      var tags;
      tags = _.filter(PrefsService.tags, function(t) {
        return t.name.indexOf('shop-') !== -1;
      });
      _.each(tags, function(t) {
        ShopService.doCache(t.name.slice(5), function(d) {
          var dealsToAdd;
          if (d && d.deals) {
            dealsToAdd = _.map(d.deals, function(e) {
              e.shop = t.name.slice(5);
              return e;
            });
            root.deals = root.deals.concat(dealsToAdd);
          }
          console.log(root.deals);
        });
      });
    };
    root.getDeals();
    root.findDeals = function(name) {
      return _.filter(root.deals, function(d) {
        return d.relatesTo.indexOf(name) !== -1;
      });
    };
  });

  this.app.factory('FoodStuffService', function($http) {
    return {
      get: function(cb) {
        $http({
          method: 'get',
          url: '/foodstuffs'
        }).success(function(data) {
          cb && cb(data.data);
        });
      },
      add: function(list, cb) {
        $http({
          method: 'post',
          url: '/foodstuffs',
          data: angular.toJson(list)
        }).success(function(data) {
          cb && cb(data);
        });
      },
      remove: function(list, cb) {
        $http({
          method: 'delete',
          url: '/foodstuffs/' + list.name,
          data: angular.toJson(list)
        }).success(function(data) {
          cb && cb(data);
        });
      },
      update: function(list, cb) {
        $http({
          method: 'put',
          url: '/foodstuffs/' + list.name,
          data: angular.toJson(list)
        }).success(function(data) {
          cb && cb(data);
        });
      }
    };
  });

  this.app.factory('PrefsService', function($http) {
    return {
      tags: [],
      getTags: function(callback) {
        var root;
        root = this;
        $http({
          method: 'get',
          url: '/settings/tags'
        }).success(function(data) {
          root.tags = data.tags;
          callback && callback(root.tags);
        });
      }
    };
  });

  this.app.controller('NavController', function($scope) {
    $scope.owner = _.last(location.pathname.split('/')).replace('/', '');
  });

  this.app.factory('ShopService', function($http) {
    return {
      cache: {},
      gettingCache: [],
      getMatchesFor: function(item, shop, callback) {
        var cont, that;
        cont = function() {
          callback(_.filter(cache[shop] || [], function(i) {
            return i.relatedTo.indexOf(item) !== -1;
          }));
        };
        console.log(this.cache, shop);
        if (!this.cache[shop]) {
          that = this;
          this.doCache(shop, function() {
            console.log(that.cache);
          });
        }
      },
      doCache: function(shop, callback) {
        var that;
        that = this;
        if (this.gettingCache.indexOf(shop) !== -1) {
          return;
        }
        this.gettingCache.push(shop);
        $http({
          method: 'get',
          url: '/shops/' + shop + '/deals.json'
        }).success(function(data) {
          that.cache[shop] = data;
          callback && callback(data);
        });
      }
    };
  });

  this.app.controller('SettingsController', function($scope, $http) {
    var root;
    root = $scope;
    root.user = {};
    root.getTags = function() {
      $http({
        method: 'get',
        url: '/settings/tags'
      }).success(function(data) {
        root.user.tags = data.tags;
      });
    };
    root.getTags();
    root.addTag = function(name) {
      $http({
        method: 'post',
        url: '/settings/tag',
        data: {
          name: name
        }
      }).success(function(data) {
        root.user.tags.push({
          name: name,
          color: 'danger'
        });
      });
    };
    root.removeTag = function(t) {
      $http({
        method: 'delete',
        url: '/settings/tag/' + t.name
      }).success(function(data) {
        console.log(root.user.tags);
        root.user.tags = _.without(root.user.tags, t);
      });
    };
  });

}).call(this);
