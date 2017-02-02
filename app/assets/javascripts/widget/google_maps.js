
var googleMapsScriptURL = '//maps.googleapis.com/maps/api/js?client=gme-greatschoolsinc&amp;libraries=geometry&amp;sensor=false&amp;signature=qeUgzsyTsk0gcv93MnxnJ_0SGTw=';
var callbackFunction = 'GS.googleMap.applyAjaxInitCallbacks';
// .getScript(googleMapsScriptURL + '&callback=' + callbackFunction);

loadScript(googleMapsScriptURL + '&callback=' + callbackFunction, function(){
  //initialization code
});

function loadScript(url, callback){

  var script = document.createElement("script");
  script.type = "text/javascript";

  if (script.readyState){  //IE
    script.onreadystatechange = function(){
      if (script.readyState == "loaded" ||
          script.readyState == "complete"){
        script.onreadystatechange = null;
        callback();
      }
    };
  } else {  //Others
    script.onload = function(){
      callback();
    };
  }

  script.src = url;
  document.getElementsByTagName("head")[0].appendChild(script);
}
var GS = GS || {};
GS.widget_map = GS.widget_map || {};
GS.widget_map.map = GS.widget_map.map || {};
GS.widget_map.mapMarkers = GS.widget_map.mapMarkers || [];

GS.googleMap = GS.googleMap || (function() {

  var ajaxInitCallbacks = [];
  var needsInit = true;

  var additionalZoom = 0;

  var init = function(sprite_files, map_points) {

      if (!needsInit) {return;}
      needsInit = false;
      if(sprite_files != undefined) {

        var points = [];
        points = map_points;

        var imageUrlPublicSchools = sprite_files['imageUrlPublicSchools'];
        var imageUrlPrivateSchools = sprite_files['imageUrlPrivateSchools'];

        var optionalLat = optionalLat || 37.807778;
        var optionalLon = optionalLon || -122.265149;

        var centerPoint = new google.maps.LatLng(optionalLat, optionalLon);
        var bounds = new google.maps.LatLngBounds();

        var initialize = function (points) {
          var isdraggable = true;

          var isZoomControl = function(){
            return true;
          };

          var myOptions = {
            center: centerPoint,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            disableDefaultUI: true,
            mapTypeControl: false,
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
            maxZoom: 19,
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

            GS.widget_map.map = new google.maps.Map(document.getElementById("js-map-canvas"), myOptions);

            var position;
            var imageUrl;
            var imageSize;
            var imageAnchor;
            var pixelOffset;
            var sizePins = new google.maps.Size(31, 40);
            var anchorPoint = new google.maps.Point(15,40);
            var infoWindow = new google.maps.InfoWindow({});
            for (var i = 0; i < points.length; i++) {
                var point = points[i];
                position = new google.maps.LatLng(point.lat, point.lng);
                bounds.extend(position);
                markerOptions = {
                    position: position,
                    map: getMap(),
                    title: point.name,
                    schoolId: point.id
                };

                if (!(parseInt(point.gsRating) > 0 && parseInt(point.gsRating) < 11)) {
                    point.gsRating = '';
                }

                if (point['zIndex'] != undefined) {
                    markerOptions['zIndex'] = point['zIndex']
                }

                var markerOptions = new google.maps.Marker(markerOptions);
                if(point.schoolType == 'Private') {
                  imageUrl = imageUrlPrivateSchools;
                }else {
                  imageUrl = imageUrlPublicSchools;
                }
                if (point.on_page) {
                    imageSize = sizePins;
                    imageAnchor = anchorPoint; // center of image
                    if ((point.preschool && parseInt(point.gsRating) == 0) || point.gsRating == "") {
                      pixelOffset = 310;
                    } else {
                      pixelOffset = parseInt(point.gsRating) * 31 -31;
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
                            infoWindow.open(getMap(), marker);
                        }
                    })(marker, point));
                }
                GS.widget_map.mapMarkers.push(marker);

                // Responsive map sizing and centering
                var center;
                var calculateCenter = function () {
                    center = getMap().getCenter();
                };

                google.maps.event.addDomListener(getMap(), 'idle', function() {
                    calculateCenter();
                });
                google.maps.event.addDomListener(window, 'resize', function() {
                    getMap().setCenter(center);
                });

            }
            if (!bounds.isEmpty()) {
                getMap().setCenter(bounds.getCenter(), getMap().fitBounds(bounds));
                google.maps.event.addListenerOnce(getMap(), 'bounds_changed', function() {
                  if($("#zoom").val() != ''){
                    var zoomStart = parseInt($("#zoom").val());
                    if(0 < zoomStart < 19){
                      GS.widget_map.map.setZoom(zoomStart);
                    }
                  }
                });
            } else {
                getMap().setOptions({maxZoom:null});
            }
          };

          var getInfoWindowMarkup = function (point) {
              var infoWindowMarkup = document.createElement('div');
              var markup = '<div class="gs-info-window">'; //school data
              var assignedLevel = point.assignedLevel;
              if (assignedLevel) {
                  markup += '<div><span class="notranslate">' + mapPinAssignedSchoolText() + '*</span></div>';
              }
              markup += '<div class="notranslate iw-school-name"><a class="" href="' + point.profileUrl + '">' + point.name + '</a></div>';
              markup += '<div class="">'; //row

              markup += '<div class="">';
              markup += '<div class="">'; //address
              markup += '<div class="notranslate iw-school-address">' + point.street + '<br/>' + point.city + ', ' + point.state.toUpperCase() + ' ' + point.zipcode + '</div>';

              var schoolType = point.schoolType;
              var stText = /charter/i.test(schoolType) ? mapPinSchoolTypeCharterText() : /private/i.test(schoolType) ? mapPinSchoolTypePrivateText() : mapPinSchoolTypePublicText();
              markup += '<div class="notranslate iw-school-type">' + stText + ' | ' + point.gradeRange + '</div>';

              markup += '</div>';//address
              markup += '</div>'; //
              markup += '<div class="">'; //sprites
              //markup += '<div class="pbs">' + '<span class="vam mrs iconx24-icons i-24-new-ratings-';
              if (point.gsRating != '') {
                var ratingShape = 'rating-circle circle-rating--small rating_'+point.gsRating;
                var textFormatting = 'circle-side-text';
                if(point.schoolType == 'Private') {
                  ratingShape = 'rating-circle diamond-rating--small rating_'+point.gsRating;
                  var textFormatting = 'diamond-side-text';
                }
                markup += '<div class="" style="position: relative"><div class="'+ ratingShape + '">';
                markup += '<div>' + point.gsRating + '</div></div><div class="'+ textFormatting +'">' + mapPinRatingText() +  '</div></div>';
              }


              markup += '</div>'; //sprites
              markup += '</div>'; //
              markup += '</div>'; //school data
              markup += '<hr class="mvm">';
              markup += '<div class="gs-info-window">';
              markup += '<div class="iw-review">'; //stars
              if (point.numReviews > 0) {
                  markup += '<a href="' + point.reviewUrl + '">' + '<span class="">'+ mapPinCommunityStars(point.communityRatingStars) + '</span>';
                  markup += '<span class="notranslate">'+ point.numReviews;
                  if (point.numReviews != 1) {
                      markup += '&nbsp;' + mapPinReviewsText() + ' </span>';
                  } else {
                      markup += '&nbsp;' + mapPinReviewText() + ' </span>';
                  }//reviews link
                  markup += '</a>';//reviews link
              } else {
                  markup += '<a class="notranslate" href="' + point.reviewUrl + '">' + mapPinRateThisSchoolText() + '</a>';
              }
              markup += '</div>'; //stars
              // markup += '<div class="iw-home">'; //zillow
              // markup += '<a class="clearfix" href="' + point.zillowUrl + '" rel="nofollow" target="_blank">';
              // markup += '<div class=""><span class="icon-house iw-house"></span>&nbsp;Homes</div>';
              // markup += '</a>';
              // markup += '</div>'; //zillow
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
          var mapPinCommunityStars = function(rating) { return $('.js-mapPinCommunityStars-' + rating).html() };

          initialize(points);

      }
    };

    var checkResize = function() {
      // needed for when displayTab=search because map is not displayed
      // so Google Maps can't calculate map dimensions
      var map = getMap();
      google.maps.event.trigger(map, 'resize');
    }

    var initAndShowMap = function (sprite_files, map_points) {
        init(sprite_files, map_points);
        var map = getMap();
        var center = map.getCenter();
        google.maps.event.trigger(map, 'resize');
        map.setCenter(center);
    };

    var setHeightForMap = function(height) {
        $('#js-map-canvas').css('height', height + 'px');
    };


    var getMap = function () {
     return GS.widget_map.map;
    };

    var removeMapMarkerBySchoolId = function (schoolId) {
      for (var i = 0; i < GS.widget_map.mapMarkers.length; i++) {
        if (schoolId == GS.widget_map.mapMarkers[i].schoolId) {
          GS.widget_map.mapMarkers[i].setMap(null);
        }

      }
    };

    var removeAllMapMarkers = function () {
      for (var i = 0; i < GS.widget_map.mapMarkers.length; i++) {
        GS.widget_map.mapMarkers[i].setMap(null);
      }
    };

    var addToInitDependencyCallbacks = function (func) {
      ajaxInitCallbacks.push(func);
    };

    var applyAjaxInitCallbacks = function () {
      while (ajaxInitCallbacks.length > 0) {
        (ajaxInitCallbacks.shift())();
      }
    };

    var setAdditionalZoom = function (addition) {
      additionalZoom = addition;
    };

    return {
      init: init,
      getMap: getMap,
      removeMapMarkerBySchoolId: removeMapMarkerBySchoolId,
      removeAllMapMarkers: removeAllMapMarkers,
      setHeightForMap: setHeightForMap,
      initAndShowMap : initAndShowMap,
      addToInitDependencyCallbacks: addToInitDependencyCallbacks,
      applyAjaxInitCallbacks: applyAjaxInitCallbacks,
      setAdditionalZoom: setAdditionalZoom,
      checkResize: checkResize
    }

})();
$(function() {
  GS.googleMap.addToInitDependencyCallbacks(function(){GS.googleMap.initAndShowMap(gon.sprite_files, gon.map_points)});
});

