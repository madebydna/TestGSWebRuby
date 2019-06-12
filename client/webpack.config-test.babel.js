// The name of this file matters (it seems to need the -babel suffix)
// in order to work with mocha-webpack

const webpack = require('webpack');
const path = require('path');
import nodeExternals from 'webpack-node-externals';
const devBuild = process.env.NODE_ENV !== 'production';

export default {
  mode: devBuild ? 'development' : 'production',
  target: 'node',
  externals: [nodeExternals()],
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
    new webpack.DefinePlugin({window: {}})
  ],
  module: {
    rules: [
      {
        test: /\.(jpe?g|png|gif|svg)$/i,
        use: 'null-loader'
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
      },
      {
        test: /\.jsx$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      }
    ]
  }
};
