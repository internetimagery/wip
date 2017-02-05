# Process stuff

gulp = require 'gulp'
coffee = require 'gulp-coffee'
mocha = require 'gulp-mocha'
ffbinaries = require 'ffbinaries'
path = require 'path'

# Compile coffeescript and run tests
gulp.task "test", ->
  gulp.src "test/*.coffee"
  .pipe coffee()
  .pipe gulp.dest "test"
  .pipe mocha()

# Download binaries, ie ffmpeg
gulp.task "binaries", ->

  ffbinaries.downloadFiles ffbinaries.detectPlatform(), {
    components:["ffmpeg"],
    destination: path.join __dirname, "src", "binaries"
  }, ->
    console.log "Done."
