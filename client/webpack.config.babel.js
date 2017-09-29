/* eslint comma-dangle: ["error",
  {"functions": "never", "arrays": "only-multiline", "objects":
"only-multiline"} ] */

const webpack = require('webpack');
const path = require('path');
const devBuild = process.env.NODE_ENV !== 'production';
const nodeEnv = devBuild ? 'development' : 'production';
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
const LodashModuleReplacementPlugin = require('lodash-webpack-plugin');
import AssetMapPlugin from 'asset-map-webpack-plugin';

const config = {
  entry: {
    'commons-blocking': ['jquery', 'jquery-ujs', 'jquery.cookie'],
    'commons': ['react', 'react-dom', 'redux', 'react-redux', './app/bundles/GSWeb/vendor/tipso', './app/bundles/GSWeb/vendor/remodal', './app/bundles/GSWeb/header'],
    'widget': ['./app/bundles/GSWeb/widget'],
    'interstitial': ['./app/bundles/GSWeb/interstitial'],
    'district-boundaries': ['./app/bundles/GSWeb/district_boundaries'],
    'school-profiles': [ './app/bundles/GSWeb/school_profiles' ],
    'jquery': ['jquery'],
    'osp-admin': ['./app/bundles/GSWeb/osp_admin']
  },

  output: {
    filename: '[name]-bundle.js',
    path: '../app/assets/webpack',
    publicPath: '/assets/'
  },

  resolve: {
    extensions: ['.js', '.jsx', '.png'],
    alias: {
      react: path.resolve('./node_modules/react'),
      'react-dom': path.resolve('./node_modules/react-dom'),
    },
    modules: [
      path.resolve('./app/bundles/GSWeb'),
      path.resolve('../app/assets/images'),
      path.resolve('./node_modules')
    ]
  },
  plugins: [
    new AssetMapPlugin('asset_map.json', null),

    new webpack.optimize.CommonsChunkPlugin({
      name: 'commons-blocking',
      chunks: ['commons', 'school-profiles', 'district-boundaries', 'widget'],
      minChunks: Infinity,
    }),
    new webpack.optimize.CommonsChunkPlugin({
      name: 'commons',
      chunks: ['school-profiles', 'district-boundaries', 'widget'],
      minChunks: Infinity,
    }),
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify(nodeEnv),
      },
    }),
    new webpack.optimize.UglifyJsPlugin({
      output: {
        comments: false
      } 
    }),
    new LodashModuleReplacementPlugin()
  ],
  module: {
    rules: [
      {
        test: require.resolve("jquery"),
        loader: "expose-loader?$!expose-loader?jQuery"
      },
      {
        test: /\.(jpe?g|png|gif|svg)$/i,
        loaders: [
          {
            loader: 'file-loader',
            options: {
              name: '[name]_[hash].[ext]'
            }
          },
          {
            loader: 'image-webpack-loader'
          }
        ],
      },
      {
        test: /\.handlebars$/,
        loader: 'handlebars-loader',
        query: { 
          helperDirs: [
            __dirname + "/app/bundles/GSWeb/components/autocomplete/handlebars_helpers"
          ]
        }
      },
      {
        test: /\.jsx?$/,
        loader: 'babel-loader',
        exclude: /node_modules/,
        options: {
          plugins: ['lodash', 'transform-runtime'],
          presets: [
            [ 'es2015', { modules: false } ],
            'react',
            'stage-0'
          ]
        }
      },
    ],
  },
  node: {
    fs: "empty"
  }
};


if (devBuild) {
  console.log('Webpack dev build for Rails'); // eslint-disable-line no-console
  config.devtool = 'eval-source-map';
} else {
  console.log('Webpack production build for Rails'); // eslint-disable-line no-console
}

if (process.env.ANALYZE) {
  config.plugins.push(new BundleAnalyzerPlugin());
}

module.exports = config;
