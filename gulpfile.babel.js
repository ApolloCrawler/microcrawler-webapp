import gulp from 'gulp';
import babel from 'gulp-babel';
import eslint from 'gulp-eslint';
import install from 'gulp-install';
import mocha from 'gulp-mocha';
import flow from 'gulp-flowtype';
import gutil from 'gulp-util';
import react from 'gulp-react';
import sourcemaps from 'gulp-sourcemaps';
import webpack from 'webpack';

import webpackConfig from './webpack/webpack.config.babel';

const path = {
  bootstrap: 'node_modules/bootstrap/dist/**/*.*',
  images: [
    'client/src/**/*.png'
  ],
  sources: [
    'client/src/**/*.js',
    'client/src/**/*.jsx'
  ],
  styles: [
    'client/src/**/*.less',
    'client/src/**/*.scss',
  ],
  tests: [
    'client/test/**/*.js'
  ],
  lib: 'client/lib',
  dest: 'client/lib',
  assets: 'web/static/assets'
};

gulp.task('install', () => {
  gulp.src('./package.json')
    .pipe(install());
});

gulp.task('default', ['build']);

gulp.task('copy', ['copy-bootstrap', 'copy-images', 'copy-styles']);

gulp.task('copy-bootstrap', () => {
  return gulp.src(path.bootstrap)
    .pipe(gulp.dest(path.assets));
});

gulp.task('copy-images', () => {
  return gulp.src(path.images)
    .pipe(gulp.dest(path.dest));
});

gulp.task('copy-styles', () => {
  return gulp.src(path.styles)
    .pipe(gulp.dest(path.dest));
});

gulp.task('babel', ['copy'], () => {
  return gulp.src(path.sources)
    .pipe(sourcemaps.init())
    .pipe(babel())
    // .pipe(react({stripTypes: true}))
    .pipe(sourcemaps.write('../../web/static/assets/js/maps', {
      sourceMappingURL: (file) => {
        return '/js/maps/' + file.relative + '.map';
      }
    }))
    .pipe(gulp.dest(path.lib));
});

gulp.task('build', ['babel', 'lint', 'typecheck', 'webpack', 'test']);

gulp.task('lint', () => {
  // ESLint ignores files with "node_modules" paths.
  // So, it's best to have gulp ignore the directory as well.
  // Also, Be sure to return the stream from the task;
  // Otherwise, the task may end before the stream has finished.
  return gulp.src([...path.sources, '!node_modules/**'])
  // eslint() attaches the lint output to the "eslint" property
  // of the file object so it can be used by other modules.
    .pipe(eslint())
    // eslint.format() outputs the lint results to the console.
    // Alternatively use eslint.formatEach() (see Docs).
    .pipe(eslint.format())
    // To have the process exit with an error code (1) on
    // lint error, return the stream and pipe to failAfterError last.
    .pipe(eslint.failAfterError());
});

gulp.task('test', ['babel'], () => {
  return gulp.src(path.tests)
    .pipe(mocha())
    .on('error', () => {
      gulp.emit('end');
    });
});

gulp.task('typecheck', () => {
  return gulp.src(path.sources)
    .pipe(flow({
      all: false,
      weak: false,
      declarations: './declarations',
      killFlow: false,
      beep: true,
      abort: false
    }));
});

gulp.task('watch-test', () => {
  return gulp.watch([path.sources, path.tests], ['build']);
});

gulp.task('webpack', ['test'], (callback) => {
  var myConfig = Object.create(webpackConfig);
  myConfig.plugins = [
    // new webpack.optimize.DedupePlugin(),
    // new webpack.optimize.UglifyJsPlugin()
  ];

  // run webpack
  webpack(myConfig, (err, stats) => {
    if (err) throw new gutil.PluginError('webpack', err);
    gutil.log('[webpack]', stats.toString({
      colors: true,
      progress: true
    }));
    callback();
  });
});

gulp.task('watch', ['build'], () => {
  gulp.watch([...path.sources, ...path.styles, ...path.tests], ['build']);
});
