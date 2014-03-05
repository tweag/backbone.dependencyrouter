'use strict';

module.exports = function (config) {
  config.set({

    // base path, that will be used to resolve files and exclude
    basePath: './',


    // frameworks to use
    frameworks: ['mocha'],


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: false,


    // list of files / patterns to load in the browser
    files: [
      // include dependencies
      'app/bower_components/jquery/dist/jquery.js',
      'app/bower_components/underscore/underscore.js',
      'app/bower_components/backbone/backbone.js',
      'app/bower_components/backbone.marionette/lib/backbone.marionette.js',
      'app/bower_components/chai/chai.js',
      'app/bower_components/sinon/lib/sinon.js',

      // include our JavaScript files
      'src/backbone.dependencyrouter.coffee',

      // simple patterns to load the needed testfiles
      // equals to {pattern: 'test/*-test.js', watched: true, served: true, included: true}
      'test/*-test.coffee',

    ],


    // list of files to exclude
    exclude: [

    ],

    // test results reporter to use
    // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['progress'],

    // configure the html reporter.
    // this will output reports in the test/report dir which can be opened
    // and viewed in your browser
    htmlReporter: {
      outputDir: 'test/report',
      templatePath: './node_modules/karma-html-reporter/jasmine_template.html'
    },

    // configure the code coverage reporter.
    // this will output coverage reports in the test/coverage dir using Istanbul
    coverageReporter: {
      type: 'html',
      dir: 'test/coverage/'
    },

    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,

    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,

    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera (has to be installed with `npm install karma-opera-launcher`)
    // - Safari (only Mac; has to be installed with `npm install karma-safari-launcher`)
    // - PhantomJS
    // - IE (only Windows; has to be installed with `npm install karma-ie-launcher`)
    browsers: ['PhantomJS'],

    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,

    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: true
  });
};
