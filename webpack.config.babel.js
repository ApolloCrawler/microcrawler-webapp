import path from 'path';

module.exports = {
	entry: {
	  main: './client/lib/index.js'
	},
	output: {
		path: path.join(__dirname, 'web', 'static', 'assets', 'js'),
		publicPath: '../dist/',
		filename: '[name].bundle.js',
		chunkFilename: '[id].bundle.js',
        libraryTarget: 'var',
        library: 'Microcrawler'
	}
};
