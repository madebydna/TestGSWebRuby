// The name of this file matters (it seems to need the -babel suffix)
// in order to work with mocha-webpack

import nodeExternals from 'webpack-node-externals';
 
export default {
  target: 'node',
  externals: [nodeExternals()],
  module: {
    loaders: [
      {
        test: /\.jsx$/,
        loader: "babel-loader"
      }
    ]
  }
};
