GS.search = GS.search || {};
GS.search.googleMap = GS.search.googleMap || (function() {

    var needsInit = true;
    GS.search.map = GS.search.map || {};

  var init = function() {
      if (!needsInit) {return;}
      needsInit = false;
      if(gon.sprite_files != undefined) {


          var points = [];
          //          lodash sytax
          _(gon.map_points).each(function (point) {
              points.push(point);
          });

          var imageUrlOnPage = gon.sprite_files['imageUrlOnPage'];
          var imageUrlOffPage = gon.sprite_files['imageUrlOffPage'];

          var optionalLat = optionalLat || 37.807778;
          var optionalLon = optionalLon || -122.265149;
          var centerPoint = new google.maps.LatLng(optionalLat, optionalLon);
          var bounds = new google.maps.LatLngBounds();

          var initialize = function (points) {
              var isdraggable = true;
              var myOptions = {
                  center: centerPoint,
                  mapTypeId: google.maps.MapTypeId.ROADMAP,
                  disableDefaultUI: true,
                  mapTypeControl: true,
                  mapTypeControlOptions: {
                      mapTypeIds: [google.maps.MapTypeId.ROADMAP, google.maps.MapTypeId.SATELLITE]
                  },
                  zoomControl: true,
                  zoomControlOptions: {
                      style: google.maps.ZoomControlStyle.DEFAULT
                  },
                  streetViewControl: true,
                  panControl: true,
                  scrollwheel: false,
                  draggable: isdraggable,
                  zoom: 12,
                  styles: [
                      {
                          "featureType": "road.highway",
                          "elementType": "geometry.fill",
                          "stylers": [
                              { "color": "#f5f5f5" }
                          ]
                      },{
                          "featureType": "road.highway",
                          "elementType": "geometry.stroke",
                          "stylers": [
                              { "color": "#f5f5f5" }
                          ]
                      },{
                          "featureType": "road.highway",
                          "elementType": "labels",
                          "stylers": [
                              { "visibility": "off" }
                          ]
                      },{
                          "featureType": "poi",
                          "elementType": "labels",
                          "stylers": [
                              { "visibility": "simplified" }
                          ]
                      },{
                          "featureType": "poi.school",
                          "elementType": "labels",
                          "stylers": [
                              { "visibility": "off" }
                          ]
                      },{
                          "featureType": "poi.school",
                          "elementType": "geometry",
                          "stylers": [
                              { "visibility": "off" }
                          ]
                      },{
                          "featureType": "poi.business",
                          "stylers": [
                              { "visibility": "off" }
                          ]
                      },{
                          "featureType": "poi.medical",
                          "elementType": "geometry",
                          "stylers": [
                              { "visibility": "off" }
                          ]
                      }
                  ]
              };
              GS.search.map = new google.maps.Map(document.getElementById("js-map-canvas"), myOptions);

              var position;
              var imageUrl;
              var imageSize;
              var imageAnchor;
              var pixelOffset;
              var size_29 = new google.maps.Size(29, 40);
              var size_10 = new google.maps.Size(10, 10);
              var point_12_20 = new google.maps.Point(12, 20);
              var point_5_5 = new google.maps.Point(5, 5);
              var infoWindow = new google.maps.InfoWindow({});

              for (var i = 0; i < points.length; i++) {
                  var point = points[i];
                  position = new google.maps.LatLng(point.lat, point.lng);
                  bounds.extend(position);
                  markerOptions = {
                      position: position,
                      map: GS.search.map,
                      title: point.name
                  };

                  if (point['zIndex'] != undefined) {
                      markerOptions['zIndex'] = point['zIndex']
                  }

                  var markerOptions = new google.maps.Marker(markerOptions);
                  if (point.on_page) {

                      imageSize = size_29;
                      imageAnchor = point_12_20; // center of image
                      if (point.preschool && parseInt(point.gsRating) == 0) {
                          pixelOffset = 290;
                          imageUrl = imageUrlOnPage;
                      } else {
                          pixelOffset = 290;// default to NR
                          if (point.gsRating != "" && parseInt(point.gsRating) > 0) {
                              pixelOffset = 290 - (parseInt(point.gsRating) * 29);
                          }
                          imageUrl = imageUrlOnPage;
                      }
                  } else {
                      imageUrl = imageUrlOffPage;
                      imageSize = size_10;
                      imageAnchor = point_5_5; // center of image

                      if (point.preschool && parseInt(point.gsRating) == 0) {
                          pixelOffset = 30;
                      } else if (parseInt(point.gsRating) >= 8) {
                          pixelOffset = 0;
                      } else if (parseInt(point.gsRating) <= 7 && parseInt(point.gsRating) > 3) {
                          pixelOffset = 10;
                      } else if (parseInt(point.gsRating) <= 3 && parseInt(point.gsRating) > 0) {
                          pixelOffset = 20;
                      } else {
                          pixelOffset = 30;
                      }
                  }

                  markerOptions.icon = new google.maps.MarkerImage(
                      imageUrl, // url
                      imageSize, // size
                      new google.maps.Point(pixelOffset, 0), // index into sprite
                      imageAnchor // which point of the image anchors to the map
                  );

                  var marker = new google.maps.Marker(markerOptions);

                  google.maps.event.addListener(marker, 'click', (function (marker, point) {
                      return function () {
                          infoWindow.setContent(getInfoWindowMarkup(point));
                          infoWindow.open(GS.search.map, marker);
                      }
                  })(marker, point));

                  // Responsive map sizing and centering
                  var center;
                  var calculateCenter = function () {
                      center = GS.search.map.getCenter();
                  };
                  google.maps.event.addDomListener(GS.search.map, 'idle', function() {
                      calculateCenter();
                  });
                  google.maps.event.addDomListener(window, 'resize', function() {
                      GS.search.map.setCenter(center);
                  })

              }
              if (!bounds.isEmpty()) {
                  GS.search.map.setCenter(bounds.getCenter(), GS.search.map.fitBounds(bounds));
              }
          };
          var getInfoWindowMarkup = function (point) {
              var infoWindowMarkup = document.createElement('div');
              var markup = '<div class="">'; //school data
              markup += '<div class="pbm"><a class="font-size-medium" href="' + point.profileUrl + '">' + point.name + '</a></div>';
              markup += '<div class="row">'; //row

              markup += '<div class="col-xs-8 col-sm-9">';
              markup += '<div class="mrl">'; //address
              markup += '<div>' + point.street + ',' + '<br/>' + point.city + ' ' + point.state.toUpperCase() + ' ' + point.zipcode + '</div>';
              markup += '<div class="mts">' + point.schoolType + ' | ' + point.gradeRange + '</div>';
              markup += '</div>';//address
              markup += '</div>'; //
              markup += '<div class="mts col-xs-4 col-sm-3">'; //sprites
              markup += '<div class="pbs">' + '<span class="vam mrs iconx24-icons i-24-new-ratings-'
              if (parseInt(point.gsRating) > 0){
                  markup += + point.gsRating;
              } else {
                  markup += 'nr';
              }
              markup += '"></span>Rating' +  '</div>'

              if(point.fitScore > 0){
                  if (point.strongFit){
                      markup += '<div class="pts">' + '<span class="vam mrs iconx24-icons i-24-happy-face"></span>Strong fit' + '</div>';
                  } else if (point.okFit){
                      markup += '<div class="pts">' + '<span class="vam mrs iconx24-icons i-24-smiling-face"></span>OK fit' + '</div>';
                  } else {
                      markup += '<div class="pts">' + '<span class="vam mrs iconx24-icons i-24-neutral-face"></span>Low fit' + '</div>';
                  }
              }
              markup += '</div>'; //sprites

              markup += '</div>'; //

              markup += '</div>'; //school data
              markup += '<hr class="mvm">';
              markup += '<div class="clearfix">';
              markup += '<div class="fl mrs">'; //stars
              if (point.numReviews > 0) {
                  markup += '<a href="' + point.reviewUrl + '">' + '<span class="vam">'+ point.communityRatingStars+ '</span>';
//                  markup += '<a href="' + point.reviewUrl + '">' + point.communityRatingStars;
                  markup += '<span class="mls mrm">'+ point.numReviews;
                  if (point.numReviews != 1) {
                      markup += ' reviews </span>';
                  } else {
                      markup += ' review </span>';
                  }//reviews link
                  markup += '</a>';//reviews link
              } else {
                  markup += '<a href="' + point.reviewUrl + '">Rate this school now!</a>';
              }
              markup += '</div>'; //stars
              markup += '<div class="fr">'; //zillow
              markup += '<a class="clearfix" href="' + point.zillowUrl + '" target="_blank">';
              markup += '<div class="fl mrs pt3"><span class="iconx16 i-16-home"></span></div><div class="fl gray-dark hidden-xs">Homes for sale</div><div class="fl gray-dark visible-xs">Homes</div>';
              markup += '</a>';
              markup += '</div>'; //zillow
              markup += '</div>';


              infoWindowMarkup.innerHTML = markup;
              return infoWindowMarkup;
          };

          initialize(points);
      }
    };

    var getMap = function () {
     return GS.search.map;
    };

    return {
        init: init,
        getMap: getMap
    }

})();
