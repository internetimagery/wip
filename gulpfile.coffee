# Process stuff

gulp = require 'gulp'
coffee = require 'gulp-coffee'
mocha = require 'gulp-mocha'

gulp.task "test", ->
  gulp.src "test/*.coffee"
  .pipe coffee()
  .pipe gulp.dest "test"
  .pipe mocha()
