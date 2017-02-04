# Process stuff

gulp = require 'gulp'
coffee = require 'gulp-coffee'


gulp.task "test", ->
  gulp.src "test/*.coffee"
  .pipe coffee()
  .pipe gulp.dest "test"
