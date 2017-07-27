/* eslint comma-dangle: ["error",
  {"functions": "never", "arrays": "only-multiline", "objects":
"only-multiline"} ] */

const webpack = require('webpack');
const path = require('path');

const devBuild = process.env.NODE_ENV !== 'production';
const nodeEnv = devBuild ? 'development' : 'production';

const config = {
  entry: {
    'school-profile-blocking': ['jquery', 'jquery-ujs', 'jquery.cookie', 'lodash', 'jquery-unveil'],
    'widget': ['./app/bundles/GSWeb/widget'],
    'district-boundaries': ['./app/bundles/GSWeb/district_boundaries'],
    'webpack': [
      './app/bundles/GSWeb/application'
    ]
  },

  output: {
    filename: '[name]-bundle.js',
    path: '../app/assets/webpack',
    publicPath: '/assets/'
  },

  resolve: {
    extensions: ['.js', '.jsx'],
    alias: {
      react: path.resolve('./node_modules/react'),
      'react-dom': path.resolve('./node_modules/react-dom'),
    },
  },
  plugins: [
     new webpack.optimize.CommonsChunkPlugin({
       name: 'school-profile-blocking',
       minChunks: Infinity,
    }),
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify(nodeEnv),
      },
    })
  ],
  module: {
    rules: [
      {
        test: require.resolve("jquery"),
        loader: "expose-loader?$!expose-loader?jQuery"
      },
      {
        test: /\.(jpe?g|png|gif|svg)$/i,
        loader: 'file-loader'
      },
      {
        test: /\.jsx?$/,
        loader: 'babel-loader',
        exclude: /node_modules/,
        options: {
          plugins: ['transform-runtime'],
          presets: [
            [ 'es2015', { modules: false } ],
            'react',
            'stage-0'
          ]
        }
      },
    ],
  },
};


if (devBuild) {
  console.log('Webpack dev build for Rails'); // eslint-disable-line no-console
  config.devtool = 'eval-source-map';
} else {
  console.log('Webpack production build for Rails'); // eslint-disable-line no-console
}
module.exports = config;
