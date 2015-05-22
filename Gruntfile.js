'use strict';

module.exports = function (grunt) {
  // load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(function(contrib) {
    grunt.log.ok([contrib + " is loaded"]);
    grunt.loadNpmTasks(contrib);
  });

  var config = {
    dist: 'dist',
    src: 'src',
    distTest: 'test/dist',
    srcTest: 'test/src',
    pkg: grunt.file.readJSON('package.json')
  };

  // Project configuration.
  grunt.initConfig({
    config: config,
    clean: {
      dist: {
        files: [
          {
            dot: true,
            src: [
              '<%= config.dist %>/*',
              '<%= config.distTest %>/*',
              '!<%= config.dist %>/.git*'
            ]
          }
        ]
      },
    },
    coffee: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= config.src %>',
          src: '{,*/}*.coffee',
          dest: '<%= config.dist %>',
          ext: '.js'
        }]
      },
      test: {
        files: [{
          expand: true,
          cwd: '<%= config.srcTest %>',
          src: '{,*/}*.spec.coffee',
          dest: '<%= config.distTest %>',
          ext: '.spec.js'
        }]
      },
      frontend: {
        files: [{
          expand: true,
          cwd: 'src/frontend',
          src: '{,*/}*.coffee',
          dest: 'public/js',
          ext: '.js'
        }]
      }
    },
    jshint: {
      options: {
        jshintrc: '.jshintrc'
      },
      gruntfile: {
        src: 'Gruntfile.js'
      },
    },
    watch: {
      gruntfile: {
        files: '<%= jshint.gruntfile.src %>',
        tasks: ['jshint:gruntfile']
      },
      dist: {
        files: '<%= config.src %>/*',
        tasks: ['coffee:dist', 'simplemocha:backend']
      },
      test: {
        files: '<%= config.srcTest %>/specs/*',
        tasks: ['coffee:test', 'simplemocha:backend']
      },
      frontend: {
        files: 'src/frontend/**/*.coffee',
        tasks: ['coffee:frontend']
      }
    },
    simplemocha: {
      options: {
        globals: [
        'sinon',
        'chai',
        'should',
        'expect',
        'assert',
        'AssertionError',
        ],
        timeout: 3000,
        ignoreLeaks: false,
        // grep: '*.spec',
        ui: 'bdd',
        reporter: 'spec'
      },
      backend: {
        src: [
          // add chai and sinon globally
          'test/support/globals.js',

          // tests
          'test/dist/**/*.spec.js',
        ],
      },
    },
    auto_install: {
      local: {},
      subdir: {
        options: {
          stdout: true,
          stderr: true,
          failOnError: true,
          npm: false
        }
      }
    },

    usebanner: {
      dist: {
        options: {
          position: 'top',
          banner: ["/*",
                " * cena_auth at version <%= config.pkg.version %>",
                " * <%= config.pkg.repository.url %>",
                " *",
                " * Copyright (c) 2015 Ryan Gaus",
                " * Licensed under the MIT license.",
                "*/"].join("\n"),
          linebreak: true
        },
        files: {
          src: ['dist/**/*.js']
        }
      }
    }
});

  grunt.registerTask('coverageBackend', 'Test backend files as well as code coverage.', function () {
    var done = this.async();

    var path = './test/support/runner.js';

    var options = {
      cmd: 'istanbul',
      grunt: false,
      args: [
        'cover',
        '--default-excludes',
        '-x', 'app/**',
        '--report', 'lcov',
        '--dir', './coverage/backend',
        path
      ],
      opts: {
        // preserve colors for stdout in terminal
        stdio: 'inherit',
      },
    };

    function doneFunction(error, result) {
      if (result && result.stderr) {
        process.stderr.write(result.stderr);
      }

      if (result && result.stdout) {
        grunt.log.writeln(result.stdout);
      }

      // abort tasks in queue if there's an error
      done(error);
    }

    grunt.util.spawn(options, doneFunction);
  });


  grunt.registerTask('bower_install', 'install frontend dependencies', function() {
    var exec = require('child_process').exec;
    var cb = this.async();
    exec('./node_modules/bower/bin/bower install', {}, function(err, stdout) {
      console.log(stdout);
      cb();
    });
  });

  // Default task.
  grunt.registerTask('default', ['coffee', 'jshint', 'usebanner']);

  grunt.registerTask('test', [
    'clean',
    'coffee',
    'simplemocha:backend',
  ]);

  grunt.registerTask('coverage', [
    'clean',
    'coffee',
    'coverageBackend',
  ]);

  grunt.registerTask('heroku', [
    'clean',
    'coffee',
    'bower_install',
  ]);

  grunt.registerTask('banner', ['usebanner']);
};
