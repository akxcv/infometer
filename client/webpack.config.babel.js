/* eslint-env node */

const { resolve } = require('path')
const webpack = require('webpack')
const ExtractTextWebpackPlugin = require('extract-text-webpack-plugin')
const HtmlWebpackPlugin = require('html-webpack-plugin')

const rawConfig = require('./config/config.json')

const env = process.env.NODE_ENV || 'development'
const config = { ...rawConfig.common, ...rawConfig[env] }

const sortChunks = () => {
  const order = ['manifest', 'vendor', 'bundle']
  return (a, b) => order.indexOf(a.names[0]) - order.indexOf(b.names[0])
}
const isDev = env === 'development'

module.exports = {
  context: resolve('src'),
  entry: {
    bundle: './',
  },
  output: {
    filename: isDev ? '[name].js' : '[name]-[chunkhash].js',
    path: resolve('dist'),
  },
  module: {
    loaders: [
      {
        test: /\.js$/,
        use: 'babel-loader',
        include: /src/,
      },
      {
        test: /\.vue$/,
        use: 'vue-loader',
        include: /src/,
      },
      {
        test: /\.s?css$/,
        use: isDev
          ? ['style-loader', 'css-loader', 'postcss-loader', 'sass-loader']
          : ExtractTextWebpackPlugin.extract({
            use: ['css-loader', 'postcss-loader', 'sass-loader'],
          }),
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: '../public/index.html',
      inject: 'true',
      chunksSortMode: sortChunks(),
    }),
    new webpack.DefinePlugin({
      __CONFIG__: JSON.stringify({
        env,
        ...config,
      }),
      __DEBUG__: JSON.stringify(isDev),
    }),
    ...(isDev
      ? []
      : [
        new ExtractTextWebpackPlugin('index-[contenthash].css'),
        new webpack.optimize.CommonsChunkPlugin({
          name: 'vendor',
          minChunks: ({ resource }) =>
            resource && resource.match(/node_modules/) && resource.match(/\.js$/),
        }),
        new webpack.optimize.CommonsChunkPlugin({
          async: true,
          children: true,
          minChunks: 4,
        }),
        new webpack.optimize.CommonsChunkPlugin({
          name: 'manifest',
          minChunks: Infinity,
        }),
        new webpack.NamedModulesPlugin(),
      ]),
  ],
  devServer: {
    clientLogLevel: 'error',
    historyApiFallback: true,
    contentBase: './',
  },
  devtool: isDev ? 'cheap-module-eval-source-map' : 'source-map',
}
