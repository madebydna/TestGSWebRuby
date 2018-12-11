// This file is written in ES5 since it's not transpiled by Babel.
/* This file does the following:
 1. Sets Node environment variable
 2. Registers babel for transpiling our code for testing
 3. Disables Webpack-specific features that Mocha doesn't understand.
 4. Requires jsdom so we can test via an in-memory DOM in Node
 5. Sets up global vars that mimic a browser.
This setting assures the .babelrc dev config (which includes
 hot module reloading code) doesn't apply for tests.
 But also, we don't want to set it to production here for
 two reasons:
 1. You won't see any PropType validation warnings when
 code is running in prod mode.
 2. Tests will not display detailed error messages
 when running against production version code
*/
const path = require('path');

process.env.NODE_ENV = 'test';

// const gsweb = path.resolve('./app/bundles/GSWeb');
// const nodeModules = path.resolve('./node_modules');
// process.env.NODE_PATH = `./node_modules:./app/bundles/GSWeb`;
// console.log(process.env.NODE_PATH);

// Register babel so that it will transpile ES6 to ES5 before our tests run.
require('babel-register')();
// Disable webpack-specific features for tests since
// Mocha doesn't know what to do with them.
require.extensions['.css'] = function() {
  return null;
};
// Configure JSDOM and set global variables
// to simulate a browser environment for tests.
const jsdom = require('jsdom').jsdom;

const enzyme = require('enzyme');
const Adapter = require('enzyme-adapter-react-16');

// expose jquery for components that depends on it
const jquery = require('jquery');

enzyme.configure({ adapter: new Adapter() });

const exposedProperties = ['window', 'navigator', 'document'];
global.document = jsdom('');
global.navigator = { userAgent: 'node.js' };
global.window = document.defaultView;
global.$ = jquery;
Object.keys(document.defaultView).forEach(property => {
  if (typeof global[property] === 'undefined') {
    exposedProperties.push(property);
    global[property] = document.defaultView[property];
  }
});
documentRef = document;

process.env.NODE_PATH = `./node_modules:./app/bundles/GSWeb`;
