import path from 'path';
import webpack from 'webpack';

import ExtractTextPlugin from 'extract-text-webpack-plugin';
import WriteFilePlugin from 'write-file-webpack-plugin';

// Heavily inspired by https://github.com/ramsaylanier/WordExpress/blob/master/webpack.config.js

module.exports = {
  devtool: 'source-map',
  context: path.resolve(__dirname, '..'),
	entry: {
	  main: [
      'react-hot-loader/patch',
	    './client/lib/index.js'
    ]
	},
	output: {
		path: path.join(__dirname, '..', 'web', 'static', 'assets', 'js'),
		publicPath: '/',
		filename: '[name].bundle.js',
		chunkFilename: '[id].bundle.js',
    // libraryTarget: 'var',
    // library: 'Microcrawler'
	},
  progress: true,
  resolve: {
    modulesDirectories: [
      'client/lib',
      'node_modules'
    ],
    extensions: ['', '.json', '.js', '.jsx']
  },
  module: {
    loaders: [
      {
        test: /\.css$/,
        loader: 'style!css?modules&localIdentName=[name]---[local]---[hash:base64:5]'
      },,
      {
        test: /\.less$/,
        loaders: [
          'style',
          'css',
          'less'
        ]
      },
      {
        test: /\.png$/,
        loader: 'url-loader',
        query: {
          mimetype: 'image/png'
        }
      },
      {
        test: /\.scss$/,
        loaders: [
          'style?sourceMap',
          'css?modules&importLoaders=1&localIdentName=[name]--[local]',
          'sass?sourceMap'
        ],
        exclude: /node_modules/
      }
    ],
  },

  plugins: [
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('dev'),
      __CLIENT__: true,
      __SERVER__: false,
      __DEVELOPMENT__: true,
      __DEVTOOLS__: true  // <-------- DISABLE redux-devtools HERE
    }),
    new WriteFilePlugin(),
    new ExtractTextPlugin('app.css', {
      allChunks: true
    }),
    new webpack.optimize.OccurenceOrderPlugin(),
    new webpack.HotModuleReplacementPlugin(),
    // new webpack.optimize.DedupePlugin(),
    // new webpack.optimize.UglifyJsPlugin({
    //   compress: {
    //     warnings: false
    //   }
    // }),
    new webpack.NoErrorsPlugin(),
  ],

  node: {
    fs: 'empty'
  }
};
