path = require 'path'
webpack = require 'webpack'
autoprefixer = require 'autoprefixer'
HtmlWebpackPlugin = require 'html-webpack-plugin'
ExtractTextPlugin = require 'extract-text-webpack-plugin'

ENV = process.env.NODE_ENV || 'development'

module.exports =
  entry:
    index: './client/index.coffee'
  output:
    path: path.resolve './build'
    publicPath: '/'
    pathinfo: true
    filename: {
      development: '[name].js'
      staginig: '[name].[hash].js'
      production: '[name].[hash].js'
    }[ENV]
  devtool: {
    development: 'eval'
    staginig: 'source-map'
    production: 'source-map'
  }[ENV]
  module:
    preLoaders: [
      {
        test: /\.coffee$/
        loader: 'coffeelint'
        exclude: /node_modules/
      }
    ]
    loaders: [
      {
        test: /\.coffee$/
        loader: 'ng-annotate!coffee'
        exclude: /node_modules/
      }
      {
        test: /\.s?css$/
        loader: ExtractTextPlugin.extract('style', 'css!postcss!sass')
      }
      {
        test: /\.(png|jpg|jpe?g|gif|svg|woff|woff2|ttf|eot)(\?.+)?$/
        loader: 'file'
      }
      {
        test: /\.jade$/
        loaders: ['ngtemplate?relativeTo=' + path.resolve('./client'), 'html', 'jade-html']
        exclude: /index\.jade$/
      }
    ]
  postcss: [ autoprefixer { browsers: [ 'last 2 version' ] } ]
  resolve:
    extensions:
      ['', '.coffee', '.js']
    alias:
      app: path.resolve './client/app'
      services: path.resolve './client/services'
  plugins: do ->
    plugins = [
      new HtmlWebpackPlugin {
        template: 'html!jade-html!./client/index.jade'
        inject: 'head'
      }
      new ExtractTextPlugin if ENV == 'development' then '[name].css' else '[name].[hash].css',
      new webpack.DefinePlugin {
        'process.env': {
          NODE_ENV: ENV
        }
      }
      new webpack.ProvidePlugin {
        _: 'lodash'
      }
    ]
    if ENV != 'development'
      plugins.concat [
        new webpack.NoErrorsPlugin
        new webpack.optimize.DedupePlugin
        new webpack.optimize.UglifyJsPlugin {
          compress: {
            warnings: false
          }
        }
      ]
    plugins
