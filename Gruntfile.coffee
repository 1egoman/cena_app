'use strict'

module.exports = (grunt) ->
  # load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach (contrib) ->
    grunt.log.ok [ contrib + ' is loaded' ]
    grunt.loadNpmTasks contrib


  config =
    dist: 'dist'
    src: 'src'
    distTest: 'test/dist'
    srcTest: 'test/src'
    pkg: grunt.file.readJSON('package.json')

  # Project configuration.
  grunt.initConfig
    config: config

    clean:
      dist:
        files:
          dot: true
          src: [
            '<%= config.dist %>/*'
            '<%= config.distTest %>/*'
            '!<%= config.dist %>/.git*'
          ]
      css:
        files:
          dot: true
          src: [ 'public/sass/index.css' ]



    coffee:
      dist: files: [ {
        expand: true
        cwd: '<%= config.src %>'
        src: '{,*/}*.coffee'
        dest: '<%= config.dist %>'
        ext: '.js'
      } ]
      test: files: [ {
        expand: true
        cwd: '<%= config.srcTest %>'
        src: '{,*/}*.spec.coffee'
        dest: '<%= config.distTest %>'
        ext: '.spec.js'
      } ]
      frontend: files: [ {
        expand: true
        cwd: 'src/frontend'
        src: '{,*/}*.coffee'
        dest: 'public/js'
        ext: '.js'
      } ]


    jshint:
      options:
        jshintrc: '.jshintrc'
      gruntfile:
        src: 'Gruntfile.js'

    watch:
      gruntfile:
        files: '<%= jshint.gruntfile.src %>'
        tasks: [
          'jshint:gruntfile'
        ]
      dist:
        files: '<%= config.src %>/*'
        tasks: [
          'coffee:dist'
          'simplemocha:backend'
        ]
      test:
        files: '<%= config.srcTest %>/specs/*'
        tasks: [
          'coffee:test'
          'simplemocha:backend'
        ]
      frontend:
        files: 'src/frontend/**/*.coffee'
        tasks: [
          'coffee:frontend'
        ]
      css:
        files: 'public/sass/**/*.scss'
        tasks: [
          'clean:css'
        ]

    simplemocha:
      options:
        globals: [
          'sinon'
          'chai'
          'should'
          'expect'
          'assert'
          'AssertionError'
        ]
        timeout: 3000
        ignoreLeaks: false
        ui: 'bdd'
        reporter: 'spec'
      backend: src: [
        'test/support/globals.js'
        'test/dist/**/*.spec.js'
      ]

    auto_install:
      local: {}
      subdir:
        options:
          stdout: true
          stderr: true
          failOnError: true
          npm: false

    usebanner:
      dist:
        options:
          position: 'top'
          banner: """/*
             * cena_auth at version <%= config.pkg.version %>
             * <%= config.pkg.repository.url %>
             *
             * Copyright (c) 2015 Ryan Gaus
             * Licensed under the MIT license.
            */"""
          linebreak: true
        files:
          src: [ 'dist/**/*.js' ]


  grunt.registerTask 'coverageBackend', 'Test backend files as well as code coverage.', ->
    done = @async()
    path = './test/support/runner.js'
    options =
      cmd: 'istanbul'
      grunt: false
      args: [
        'cover'
        '--default-excludes'
        '-x'
        'app/**'
        '--report'
        'lcov'
        '--dir'
        './coverage/backend'
        path
      ]
      opts: stdio: 'inherit'

    grunt.util.spawn options, (error, result) ->
      if result and result.stderr
        process.stderr.write result.stderr
      if result and result.stdout
        grunt.log.writeln result.stdout
      # abort tasks in queue if there's an error
      done error

  grunt.registerTask 'bower_install', 'install frontend dependencies', ->
    exec = require('child_process').exec
    cb = @async()
    exec './node_modules/bower/bin/bower install', {}, (err, stdout) ->
      console.log stdout
      cb()


  # Tasks
  grunt.registerTask 'default', [
    'coffee'
    'jshint'
    'usebanner'
  ]
  grunt.registerTask 'test', [
    'clean'
    'coffee'
    'simplemocha:backend'
  ]
  grunt.registerTask 'coverage', [
    'clean'
    'coffee'
    'coverageBackend'
  ]
  grunt.registerTask 'heroku', [
    'clean'
    'coffee'
    'bower_install'
  ]
  grunt.registerTask 'banner', [ 'usebanner' ]
