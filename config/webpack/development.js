process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
// const less = require('./less')
// environment.loaders.append('less', less)

module.exports = environment.toWebpackConfig()


// const merge = require('webpack-merge')

// const myCssLoaderOptions = {
//   modules: true,
//   sourceMap: true,
//   localIdentName: '[name]__[local]___[hash:base64:5]'
// }

// const CSSLoader = environment.loaders.get('style').use.find(el => el.loader === 'css-loader')

// CSSLoader.options = merge(CSSLoader.options, myCssLoaderOptions)
// environment.loaders.get('sass').use.splice(-1, 0, {
//   loader: 'resolve-url-loader',
//   options: {
//     attempts: 1
//   }
// });

// const ExtractTextPlugin = require('extract-text-webpack-plugin');

// const less = {
//   test: /\.less$/,
//   use: ExtractTextPlugin.extract({
//     use: ['css-loader', 'less-loader']
//   })
// }

// environment.loaders.append('less', less)
// module.exports = environment

// const ExtractTextPlugin = require('extract-text-webpack-plugin');

// module: {
//   rules: [
//     ...
//     // this handles .less translation
//     {
//       use: ExtractTextPlugin.extract({
//         use: ['css-loader', 'less-loader']
//       }),
//       test: /\.less$/
//     },
//     ...
//   ]
// },
// plugins: [
//    ...
//    // this handles the bundled .css output file
//    new ExtractTextPlugin({
//      filename: '[name].[contenthash].css',
//    }),
//   ...
// ]