// // const MiniCssExtractPlugin = require('mini-css-extract-plugin');

// // module.exports = {
// //   test: /\.less$/,
// //   use: MiniCssExtractPlugin.extract({
// //     use: ['css-loader', 'less-loader']
// //   })
// // }


// // const MiniCssExtractPlugin = require('mini-css-extract-plugin');
// // module.exports = {
// //   plugins: [
// //     new MiniCssExtractPlugin({
// //       // Options similar to the same options in webpackOptions.output
// //       // both options are optional
// //       filename: '[name].css',
// //       chunkFilename: '[id].css',
// //     }),
// //   ],
// //   module: {
// //     rules: [
// //       {
// //         test: /\.less$/,
// //         use: [
// //           {
// //             loader: MiniCssExtractPlugin.loader,
// //             options: {
// //               // only enable hot in development
// //               hmr: process.env.NODE_ENV === 'development',
// //               // if hmr does not work, this is a forceful method.
// //               reloadAll: true,
// //             },
// //           },
// //           'css-loader',
// //           'less-loader'
// //         ],
// //       },
// //     ],
// //   },
// // };


// const getStyleRule = require('@rails/webpacker/package/utils/get_style_rule')

// module.exports = getStyleRule(/\.less$/i, false, [
//   {
//     loader: 'less-loader',
//     options: { sourceMap: true }
//   }
// ])