// TODO: import Uri
// import { geocode } from './components/geocoding';
// import { google_maps } from './components/map/google_maps';

// const updateIFrameUrl = function(paramName, value) {
//   let $iframe = $('.preview iframe');
//   var url = $iframe.attr('src');
//   debugger;
//   url = GS.uri.Uri.putIntoQueryString(url, paramName, value);
//   $iframe.src = url;
// };

// $(function() {
//   google_maps.init(function() {
//     $('.widget-customization input[name=address]').on('change', function(e) {
//       updateIFrameUrl(e.target.name, e.target.value);
//     });
//     $('.widget-customization input').on('change', function(e) {
//       updateIFrameUrl(e.target.name, e.target.value);
//     });
//   });
// });

import ReactOnRails from 'react-on-rails';
import Widget from './react_components/widget';
ReactOnRails.register({
  Widget
});
ReactOnRails.reactOnRailsPageLoaded();
