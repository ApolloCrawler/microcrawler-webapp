import gulp from 'gulp';
import babel from 'gulp-babel';
import mocha from 'gulp-mocha';
import gutil from 'gulp-util';
import webpack from 'webpack';
import webpackConfig from './webpack.config.babel';
import WebpackDevServer from 'webpack-dev-server';

const path = {
    sources: [
        'client/src/**/*.js'
    ],
    tests: [
        'client/test/**/*.js'
    ],
    lib: 'client/lib'
};

gulp.task('default', ['webpack']);

gulp.task('babel', () => {
  return gulp.src(path.sources)
    .pipe(babel())
    .pipe(gulp.dest(path.lib));
});

gulp.task('test', ['babel'], () => {
  return gulp.src(path.tests)
    .pipe(mocha())
    .on('error', () => {
      gulp.emit('end');
    });
});

gulp.task('watch-test', () => {
  return gulp.watch([path.sources, path.tests], ['test']);
});

gulp.task('webpack', ['test'], function(callback) {
  var myConfig = Object.create(webpackConfig);
  myConfig.plugins = [
		new webpack.optimize.DedupePlugin(),
		new webpack.optimize.UglifyJsPlugin()
  ];

  // run webpack
  webpack(myConfig, function(err, stats) {
    if (err) throw new gutil.PluginError('webpack', err);
    gutil.log('[webpack]', stats.toString({
      colors: true,
      progress: true
    }));
    callback();
  });
});

gulp.task('watch', () => {
    gulp.watch([path.sources, path.tests], ['webpack']);
});
