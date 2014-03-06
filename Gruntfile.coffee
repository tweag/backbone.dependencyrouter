module.exports =  (grunt) ->
  pattern = '{,*/}*.coffee'
  distDir = 'src/' + pattern
  testDir = 'test/' + pattern

  require('load-grunt-tasks')(grunt)

  grunt.registerTask 'default', ['coffee:dist', 'karma:unit']

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    banner: """/*! <%= pkg.name %> - v<%= pkg.version %> -
      <%= grunt.template.today("yyyy-mm-dd") %>\n
      <%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>
      * Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>
       Licensed MIT */\n"""

    watch:
      dist:
        files: [distDir, testDir]
        tasks: ['karma:unit']
        options:
          spawn: false
        karma:
          files: ['tests/*.coffee', 'src/*.coffee']
          tasks: ['karma:js:run']

    karma:
      frameworks: ["mocha", "chai", "sinon"]
      options:
        configFile: 'karma.conf.js'
      unit:
        background: false
      report:
        singleRun: true,
        browsers: ['PhantomJS'],
        reporters: ['progress', 'html', 'coverage']

     coffee:
        dist:
          files: [
            expand: false
            src: distDir
            dest: 'dist/'
            ext: '.js'
          ]
        test:
          files: [
            expand: true
            src: testDir
            dest: '.tmp'
            ext: '.js'
          ]

    uglify:
      options:
        banner: '<%= banner %>'
      dist:
        src: '<%= concat.dist.dest %>',
        dest: 'dist/jquery.<%= pkg.name %>.min.js'

    connect:
      server:
        options:
          hostname: 'localhost'
          port: 9000

