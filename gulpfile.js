(function() {
  var coffee, ffbinaries, gulp, mocha, path;

  gulp = require('gulp');

  coffee = require('gulp-coffee');

  mocha = require('gulp-mocha');

  ffbinaries = require('ffbinaries');

  path = require('path');

  gulp.task("test", function() {
    return gulp.src("test/*.coffee").pipe(coffee()).pipe(gulp.dest("test")).pipe(mocha());
  });

  gulp.task("binaries", function() {
    return ffbinaries.downloadFiles(ffbinaries.detectPlatform(), {
      components: ["ffmpeg"],
      destination: path.join(__dirname, "src", "binaries")
    }, function() {
      return console.log("Done.");
    });
  });

}).call(this);
