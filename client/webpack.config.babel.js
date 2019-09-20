/* eslint comma-dangle: ["error",
  {"functions": "never", "arrays": "only-multiline", "objects":
"only-multiline"} ] */

import AssetMapPlugin from 'asset-map-webpack-plugin';

const webpack = require('webpack');
const path = require('path');
const fs = require('fs');

const devBuild = process.env.NODE_ENV !== 'production';
const nodeEnv = devBuild ? 'development' : 'production';
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer')
  .BundleAnalyzerPlugin;
const LodashModuleReplacementPlugin = require('lodash-webpack-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');

// ! If you add a new JS file to entry object you probably need to edit
// ! assets.rb in order for the file to be served by Rails on
// ! prod/QA/single-stack machines
const config = {
  mode: devBuild ? 'development' : 'production',
  entry: {
    widget: ['polyfills', './app/bundles/GSWeb/common', './app/bundles/GSWeb/widget'],
    'mobile-overlay-ad': ['./app/bundles/GSWeb/components/ads/mobile_overlay'],
    'district-boundaries': [
      'polyfills',
      './app/bundles/GSWeb/common',
      './app/bundles/GSWeb/district_boundaries'
    ],
    'school-profiles': ['polyfills', './app/bundles/GSWeb/common', './app/bundles/GSWeb/school_profiles'],
    home: ['polyfills','./app/bundles/GSWeb/common', './app/bundles/GSWeb/home'],
    'commons-blocking-loader': ['./app/bundles/GSWeb/misc_all_page_blocking'],
    'jquery-loader': ['jquery'],
    'admin-tools': ['./app/bundles/GSWeb/admin_tools'],
    'add-schools': ['./app/bundles/GSWeb/pages/add_schools'],
    compare: ['polyfills', './app/bundles/GSWeb/common', './app/bundles/GSWeb/compare'],
    search: ['polyfills', './app/bundles/GSWeb/common', './app/bundles/GSWeb/search'],
    'college-success-award': ['polyfills', './app/bundles/GSWeb/common', './app/bundles/GSWeb/college_success_award'],
    'search-box': [
      'polyfills',
      './app/bundles/GSWeb/react_components/search_box_wrapper'
    ],
    community: ['polyfills', './app/bundles/GSWeb/common', './app/bundles/GSWeb/community'],
    account: ['polyfills', './app/bundles/GSWeb/common', './app/bundles/GSWeb/account'],
    'official-school-profile': ['polyfills', './app/bundles/GSWeb/common', './app/bundles/GSWeb/official_school_profile'],
    'reviews-page': ['polyfills', './app/bundles/GSWeb/common', './app/bundles/GSWeb/reviews_page'],
    'signin-page': ['polyfills', './app/bundles/GSWeb/common', './app/bundles/GSWeb/signin_page'],
    'default-page-just-layout': ['polyfills', './app/bundles/GSWeb/common', './app/bundles/GSWeb/default_page_just_layout'],
    'moderation-tools': ['polyfills', './app/bundles/GSWeb/common', './app/bundles/GSWeb/moderation_tools'],
  },

  optimization: {
    splitChunks: {
      chunks: 'async',
      minSize: 999999, // these all just prevent splitChunks from dynamically making chunk bundles for us
      maxSize: 0,
      minChunks: 1999,
      maxAsyncRequests: 5,
      maxInitialRequests: 3,
      automaticNameDelimiter: '~',
      name: true,
      cacheGroups: {
        vendors: false,
        // make these custom defined chunk bundles
        'commons-blocking': {
          test: /jquery/,
          name: 'commons-blocking',
          enforce: true,
          reuseExistingChunk: true,
          chunks(module, chunks) {
            if (
              module.name == 'mobile-overlay-ad' ||
              module.name == 'search-box'
            ) {
              // mobile overlay ad exists on "old" layouts w/ old deprecated JS, which means it cannot depend on webpack commons blocking
              return false;
            }
            return true;
          }
        },
        'react-redux': {
          chunks(module, chunks) {
            if (module.name == 'search-box') {
              // leave react-redux stuff in search-box bundle so GK can use it without DLing multiple files
              return false;
            }
            return true;
          },
          test: /\breact\b|react-dom|redux|react-redux|react-transition-group/,
          name: 'react-redux',
          enforce: true,
          reuseExistingChunk: true
        },
        commons: {
          chunks(module, chunks) {
            if (module.name == 'search-box') {
              // leave commons in search-box bundle so GK can use it without DLing multiple files
              return false;
            }
            return true;
          },
          test: /core-js|tipso|remodal|typeahead_modified.bundle.js|header|handlebars/,
          name: 'commons',
          enforce: true,
          reuseExistingChunk: true
        }
      }
    }
  },

  output: {
    filename: '[name]-bundle_[chunkhash].js',
    chunkFilename: '[name]-bundle_[chunkhash].js',
    path: path.resolve(__dirname, '../app/assets/webpack'),
    publicPath: '/assets/'
  },

  resolve: {
    extensions: ['.js', '.jsx', '.png'],
    alias: {
      react: path.resolve('./node_modules/react'),
      'react-dom': path.resolve('./node_modules/react-dom')
    },
    modules: [
      path.resolve('./app/bundles/GSWeb'),
      path.resolve('../app/assets/images'),
      path.resolve('./node_modules')
    ]
  },
  plugins: [
    {
      apply(compiler) {
        compiler.plugin('done', (stats, done) => {
          const assets = {};
          for (const chunkGroup of stats.compilation.chunkGroups) {
            if (chunkGroup.name) {
              let files = [];
              for (const chunk of chunkGroup.chunks) {
                files = files.concat(chunk.files);
              }
              assets[chunkGroup.name] = files;
            }
          }

          if (!process.env.ANALYZE) {
            fs.writeFile(
              path.resolve(
                __dirname,
                '../app/assets/webpack',
                'webpack.stats.json'
              ),
              JSON.stringify({
                assetsByChunkName: assets,
                publicPath: stats.compilation.outputOptions.publicPath
              }),
              done
            );
          }
        });
      }
    },
    new AssetMapPlugin('asset_map.json', null),
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify(nodeEnv)
      }
    }),
    new LodashModuleReplacementPlugin({ currying: true, flattening: true }),
    new webpack.optimize.ModuleConcatenationPlugin()
  ],
  module: {
    rules: [
      {
        test: /\.(jpe?g|png|gif|svg)$/i,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name]_[hash].[ext]'
            }
          }
        ]
      },
      {
        test: /\.handlebars$/,
        loader: 'handlebars-loader',
        query: {
          helperDirs: [
            `${__dirname}/app/bundles/GSWeb/components/autocomplete/handlebars_helpers`
          ]
        }
      },
      {
        test: /\.jsx?$/,
        use: 'babel-loader',
        exclude: /node_modules/
      },
      {
        test: require.resolve('jquery'),
        use: [
          {
            loader: 'expose-loader',
            options: 'jQuery'
          },
          {
            loader: 'expose-loader',
            options: '$'
          }
        ]
      }
    ]
  },
  node: {
    fs: 'empty'
  }
};

if (devBuild) {
  console.log('Webpack dev build for Rails'); // eslint-disable-line no-console
  config.devtool = 'eval-source-map';
} else {
  config.plugins.push(
    new UglifyJsPlugin({
      uglifyOptions: {
        output: {
          comments: false
        }
      }
    })
  );
  console.log('Webpack production build for Rails'); // eslint-disable-line no-console
}
// config["externals"] = {
//   jquery: 'jQuery',
//   "jquery-ujs": "jquery-ujs",
//   'jquery.cookie': "jquery.cookie"
// }

if (process.env.ANALYZE) {
  config.plugins.push(new BundleAnalyzerPlugin({ analyzerHost: '0.0.0.0' }));
}
module.exports = config;
