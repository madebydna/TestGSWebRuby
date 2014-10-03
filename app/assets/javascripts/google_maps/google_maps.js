GS.search = GS.search || {};
GS.window.sizing.maxMobileWidth = GS.window.sizing.maxMobileWidth || {};
GS.window.sizing.width = GS.window.sizing.width || {};
GS.search.googleMap = GS.search.googleMap || (function() {

    var needsInit = true;
    GS.search.map = GS.search.map || {};
    GS.search.mapMarkers = GS.search.mapMarkers || [];

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

              var isZoomControl = function(){

                if(((GS.window.sizing.width)()) <= GS.window.sizing.maxMobileWidth){
                    return false;
                }else{
                    return true;
                }
              };

              var myOptions = {
                  center: centerPoint,
                  mapTypeId: google.maps.MapTypeId.ROADMAP,
                  disableDefaultUI: true,
                  mapTypeControl: true,
                  mapTypeControlOptions: {
                      mapTypeIds: [google.maps.MapTypeId.ROADMAP, google.maps.MapTypeId.SATELLITE]
                  },
                  zoomControl: isZoomControl(),
                  zoomControlOptions: {
                      style: google.maps.ZoomControlStyle.DEFAULT
                  },
                  streetViewControl: false,
                  panControl: false,
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
                      title: point.name,
                      schoolId: point.id
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
                  if (point.profileUrl ) {
                      google.maps.event.addListener(marker, 'click', (function (marker, point) {
                          return function () {
                              infoWindow.setContent(getInfoWindowMarkup(point));
                              infoWindow.open(GS.search.map, marker);
                          }
                      })(marker, point));
                  }
                  GS.search.mapMarkers.push(marker);

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
              var markup = '<div>'; //school data
              var assignedLevel = point.assignedLevel;
              if (assignedLevel) {
                  markup += '<div class="mbs"><span class="notranslate font-size-small inverted-text bg-emphasis brs uc phm pvs">' + mapPinAssignedSchoolText() + '*</span></div>';
              }
              markup += '<div class="pbm notranslate" style="width: 260px;"><a class="font-size-medium" href="' + point.profileUrl + '">' + point.name + '</a></div>';
              markup += '<div class="row">'; //row

              markup += '<div class="col-xs-7 col-sm-8">';
              markup += '<div class="mrl">'; //address
              markup += '<div class="notranslate">' + point.street + ',' + '<br/>' + point.city + ' ' + point.state.toUpperCase() + ' ' + point.zipcode + '</div>';

              var schoolType = point.schoolType;
              var stText = /charter/i.test(schoolType) ? mapPinSchoolTypeCharterText() : /private/i.test(schoolType) ? mapPinSchoolTypePrivateText() : mapPinSchoolTypePublicText();
              markup += '<div class="mts notranslate">' + stText + ' | ' + point.gradeRange + '</div>';

              markup += '</div>';//address
              markup += '</div>'; //
              markup += '<div class="mts col-xs-5 col-sm-4 ">'; //sprites
              markup += '<div class="pbs">' + '<span class="vam mrs iconx24-icons i-24-new-ratings-';
              if (parseInt(point.gsRating) > 0){
                  markup += + point.gsRating;
              } else {
                  markup += 'nr';
              }
              markup += '"></span class="notranslate">' + mapPinRatingText() +  '</div>';

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
                  markup += '<span class="mls mrm font-size-small notranslate">'+ point.numReviews;
                  if (point.numReviews != 1) {
                      markup += ' ' + mapPinReviewsText() + ' </span>';
                  } else {
                      markup += ' ' + mapPinReviewText() + ' </span>';
                  }//reviews link
                  markup += '</a>';//reviews link
              } else {
                  markup += '<a class="notranslate" href="' + point.reviewUrl + '">' + mapPinRateThisSchoolText() + '</a>';
              }
              markup += '</div>'; //stars
              markup += '<div class="fr">'; //zillow
              markup += '<a class="clearfix" href="' + point.zillowUrl + '" target="_blank">';
              markup += '<div class="fl mrs pt1"><span class="iconx16 i-16-home"></span></div><div class="fl gray-dark hidden-xs font-size-small notranslate">' + mapPinHomesForSaleText() + '</div><div class="fl gray-dark visible-xs font-size-small">Homes</div>';
              markup += '</a>';
              markup += '</div>'; //zillow
              markup += '</div>';


              infoWindowMarkup.innerHTML = markup;
              return infoWindowMarkup;
          };

          var mapPinRatingText = function() { return $('.js-mapPinRatingText').text().trim() };
          var mapPinReviewText = function() { return $('.js-mapPinReviewText').text().trim() };
          var mapPinReviewsText = function() { return $('.js-mapPinReviewsText').text().trim() };
          var mapPinRateThisSchoolText = function() { return $('.js-mapPinRateThisSchoolText').text().trim() };
          var mapPinHomesForSaleText = function() { return $('.js-mapPinHomesForSaleText').text().trim() };
          var mapPinSchoolTypePrivateText = function() { return $('.js-mapPinSchoolTypePrivateText').text().trim() };
          var mapPinSchoolTypePublicText = function() { return $('.js-mapPinSchoolTypePublicText').text().trim() };
          var mapPinSchoolTypeCharterText = function() { return $('.js-mapPinSchoolTypeCharterText').text().trim() };
          var mapPinAssignedSchoolText = function() { return $('.js-mapPinAssignedSchoolText').text().trim() };

          initialize(points);

      }
    };

    var initAndShowMap = function () {
        init();
        var map = getMap();
        var center = map.getCenter();
        google.maps.event.trigger(map, 'resize');
        map.setCenter(center);
    };

    var setHeightForMap = function(height) {
        $('#js-map-canvas').css('height', height + 'px');
    };


    var getMap = function () {
     return GS.search.map;
    };

    var removeMapMarkerBySchoolId = function (schoolId) {
        _(GS.search.mapMarkers).each( function (marker) {
            if (schoolId == marker.schoolId) {
                marker.setMap(null);
            }
        });
    };

    var setAssignedSchool = function (schoolId, level) {
        if (gon.map_points) {
            _(gon.map_points).each(function (point) {
                if (point.id == schoolId) {
                    point.assignedLevel = level;
                }
            });
        }
    };

    return {
        init: init,
        getMap: getMap,
        removeMapMarkerBySchoolId: removeMapMarkerBySchoolId,
        setHeightForMap: setHeightForMap,
        initAndShowMap : initAndShowMap,
        setAssignedSchool: setAssignedSchool
    }

})();
