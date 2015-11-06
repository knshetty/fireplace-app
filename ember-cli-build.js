/* global require, module */
var EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function(defaults) {

  var app = new EmberApp(defaults, {
    // Add options here
  });

  // Use `app.import` to add additional libraries to the generated
  // output files.
  //
  // If you need to use different assets in different
  // environments, specify an object as the first parameter. That
  // object's keys should be the environment name and the values
  // should be the asset to use in that environment.
  //
  // If the library that you are including contains AMD or ES6
  // modules that you would like to import into your application
  // please specify an object with the list of modules as keys
  // along with the exports of each module as its value.

  var pickFiles = require('broccoli-static-compiler');
  var mergeTrees = require('broccoli-merge-trees');

  // --- Bootstrap UI framework's dependencies ---
  app.import('bower_components/bootstrap/dist/js/bootstrap.js');
  app.import('bower_components/bootstrap/dist/css/bootstrap.css');
  var bootstrapMap = pickFiles('bower_components/bootstrap/dist/css', {
      srcDir: '/',
      files: ['bootstrap.css.map'],
      destDir: '/assets'
  });
  var bootstrapFonts = pickFiles('bower_components/bootstrap/dist/fonts', {
      srcDir: '/',
      files: ['glyphicons-halflings-regular.woff',
              'glyphicons-halflings-regular.woff2',
              'glyphicons-halflings-regular.ttf'],
      destDir: '/fonts'
  });

  // --- Third-party Bootrap-3 themes dependencies ---
  // Darkly Theme by www.bootswatch.com
  app.import('app/styles/darkly-theme-bootstrap-bootswatch.com.css');

  // --- SVG assests ---
  var svgAssests = pickFiles('app/svgs', {
        srcDir: '/',
        files: ['clock-n-temperature.svg'],
        destDir: '/assets'
  });

  // -- Snap.svg - SVG graphics library (https://github.com/adobe-webplatform/Snap.svg) dependencies ---
  app.import('bower_components/Snap.svg/dist/snap.svg.js');

  // -- clockpicker - Time picker jQuery/Bootstrap UI component library (https://github.com/weareoutman/clockpicker) dependencies ---
  // Note! Bower package with tag#0.0.7 does not have the callbacks yet (https://github.com/weareoutman/clockpicker/issues/29)
  // Work-around for this issue:
  //    *Option 1: bower uninstall ng-clockpicker --save (Will pull the package from >> git://github.com/webdeskltd/clockpicker.git)
  //    Option 2: bower install 'https://github.com/weareoutman/clockpicker.git#gh-pages'
  app.import('bower_components/clockpicker/dist/bootstrap-clockpicker.min.css');
  app.import('bower_components/clockpicker/dist/bootstrap-clockpicker.min.js');

  // -- smalot-bootstrap-datetimepicker - DateTime picker jQuery/Bootstrap UI component library (https://github.com/smalot/bootstrap-datetimepicker) dependencies ---
  app.import('bower_components/smalot-bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css');
  app.import('bower_components/smalot-bootstrap-datetimepicker/css/datetimepicker.css'); //Note! Manually generated dependency file, build instructures here >> http://www.malot.fr/bootstrap-datetimepicker/#dependencies
  app.import('bower_components/smalot-bootstrap-datetimepicker/js/bootstrap-datetimepicker.min.js');

  // -- countdown - Countdown-Timee jQuery UI component library (https://github.com/rendro/countdown) dependencies ---
  app.import('bower_components/countdown/dest/jquery.countdown.min.js');

  return mergeTrees([app.toTree(),
                     bootstrapMap,
                     bootstrapFonts,
                     svgAssests]);
};
