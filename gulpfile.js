(function() {
  var coffee, gulp, mocha;

  gulp = require('gulp');

  coffee = require('gulp-coffee');

  mocha = require('gulp-mocha');

  gulp.task("test", function() {
    return gulp.src("test/*.coffee").pipe(coffee()).pipe(gulp.dest("test")).pipe(mocha());
  });

}).call(this);
