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
                  //              draggable: false,
                  zoom: 12
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
                  var markerOptions = new google.maps.Marker({
                      position: position,
                      map: GS.search.map
                  });
                  if (point.on_page) {

                      imageSize = size_29;
                      imageAnchor = point_12_20; // center of image
                      if (point.preschool) {
                          pixelOffset = 318;
                          imageUrl = imageUrlOnPage;
                      } else {
                          pixelOffset = 290;// default to NR
                          if (point.gsRating != "" && parseInt(point.gsRating) > 0) {
                              pixelOffset = 290 - (point.gsRating * 29);
                          }
                          imageUrl = imageUrlOnPage;
                      }
                  } else {
                      imageUrl = imageUrlOffPage;
                      imageSize = size_10;
                      imageAnchor = point_5_5; // center of image

                      if (point.preschool) {
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
              jQuery(infoWindowMarkup).css("height", 180);
              var markup = '<div style="width: 101%"><a href="' + point.profileUrl + '">' + point.name + '</a></div>';
              markup += '<div>' + point.street + ' ' + point.city + ', ' + point.state.toUpperCase() + ' ' + point.zipcode + '</div>';
              if (point.gsRating > 0) {
                  markup += "<div>Rating=" + point.gsRating + "/10</div>";
              }
              if (point.maxFitScore > 0) {
                  markup += '<div>Fit: ' + point.fitScore + '/' + point.maxFitScore + '</div>';
              }
              markup += '<div>' + point.schoolType + ' | ' + point.gradeRange + '</div>';
              markup += "<div>";
              if (point.communityRating > 0) {
                  markup += '<div><a href="' + point.reviewUrl + '">' + point.communityRatingStars + '</a>';
                  if (point.numReviews > 0) {
                      markup += ' (based on ' + point.numReviews + ' review' + (point.numReviews > 1 ? 's' : '') + ')';
                  }
              } else {
                  markup += '<a href="' + point.reviewUrl + '">Rate this school now!</a>';
              }
              markup += '</div>';
              markup += '<div><a href="' + point.zillowUrl + '" target="_blank">Nearby homes for sale</a></div>';
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

$(document).ready(function() {
    if ($.cookie('map_view') !== 'false') {
        GS.search.googleMap.init();
    }
});