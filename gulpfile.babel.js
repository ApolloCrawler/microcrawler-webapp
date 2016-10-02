import gulp from 'gulp';
import babel from 'gulp-babel';
import eslint from 'gulp-eslint';
import mocha from 'gulp-mocha';
import flow from 'gulp-flowtype';
import gutil from 'gulp-util';
import react from 'gulp-react';
import webpack from 'webpack';
import WebpackDevServer from 'webpack-dev-server';

import webpackConfig from './webpack.config.babel';

const path = {
    sources: [
        'client/src/**/*.js'
    ],
    tests: [
        'client/test/**/*.js'
    ],
    lib: 'client/lib'
};

gulp.task('default', ['build']);

gulp.task('babel', () => {
    return gulp.src(path.sources)
        .pipe(babel())
        .pipe(react({stripTypes: true}))
        .pipe(gulp.dest(path.lib));
});

gulp.task('build', ['babel', 'lint', 'typecheck', 'webpack', 'test']);

gulp.task('lint', () => {
    // ESLint ignores files with "node_modules" paths.
    // So, it's best to have gulp ignore the directory as well.
    // Also, Be sure to return the stream from the task;
    // Otherwise, the task may end before the stream has finished.
    return gulp.src([path.sources[0],'!node_modules/**'])
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
        new webpack.optimize.DedupePlugin(),
        new webpack.optimize.UglifyJsPlugin()
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

gulp.task('watch', () => {
    gulp.watch([path.sources, path.tests], ['build']);
});
