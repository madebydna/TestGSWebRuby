// GS.window.sizing.maxMobileWidth = GS.window.sizing.maxMobileWidth || {};
// GS.window.sizing.width = GS.window.sizing.width || {};
var googleMapsScriptURL = '//maps.googleapis.com/maps/api/js?client=gme-greatschoolsinc&amp;libraries=geometry&amp;sensor=false&amp;signature=qeUgzsyTsk0gcv93MnxnJ_0SGTw=';
var callbackFunction = 'GS.googleMap.applyAjaxInitCallbacks';
// .getScript(googleMapsScriptURL + '&callback=' + callbackFunction);

loadScript(googleMapsScriptURL + '&callback=' + callbackFunction, function(){
  //initialization code
});

function loadScript(url, callback){

  var script = document.createElement("script")
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

GS.googleMap = GS.googleMap || (function() {

    var ajaxInitCallbacks = [];
    var needsInit = true;

    GS.widget = GS.widget || {};
    GS.widget.map = GS.widget.map || {};
    GS.widget.mapMarkers = GS.widget.mapMarkers || [];
    var additionalZoom = 0;

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
              GS.widget.map = new google.maps.Map(document.getElementById("js-map-canvas"), myOptions);

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
                              infoWindow.open(getMap(), marker);
                          }
                      })(marker, point));
                  }
                  GS.widget.mapMarkers.push(marker);

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
                  })

              }
              if (!bounds.isEmpty()) {
                  getMap().setCenter(bounds.getCenter(), getMap().fitBounds(bounds));
                  google.maps.event.addListenerOnce(getMap(), 'bounds_changed', function() {
                      if (additionalZoom !== 0) {
                        getMap().setZoom(getMap().getZoom() + additionalZoom);
                      }
                      getMap().setOptions({maxZoom:null});
                  });
              } else {
                  getMap().setOptions({maxZoom:null});
              }
          };
          var getInfoWindowMarkup = function (point) {
              var infoWindowMarkup = document.createElement('div');
              var markup = '<div>'; //school data
              var assignedLevel = point.assignedLevel;
              if (assignedLevel) {
                  markup += '<div class="mbs"><span class="notranslate font-size-small inverted-text bg-neutral brs uc phm pvs">' + mapPinAssignedSchoolText() + '*</span></div>';
              }
              markup += '<div class="pbm notranslate" style="width: 260px;"><a class="font-size-medium" href="' + point.profileUrl + '">' + point.name + '</a></div>';
              markup += '<div class="row">'; //row

              markup += '<div class="col-xs-7 col-sm-8">';
              markup += '<div class="mrl">'; //address
              markup += '<div class="notranslate">' + point.street + '<br/>' + point.city + ', ' + point.state.toUpperCase() + ' ' + point.zipcode + '</div>';

              var schoolType = point.schoolType;
              var stText = /charter/i.test(schoolType) ? mapPinSchoolTypeCharterText() : /private/i.test(schoolType) ? mapPinSchoolTypePrivateText() : mapPinSchoolTypePublicText();
              markup += '<div class="mts notranslate">' + stText + ' | ' + point.gradeRange + '</div>';

              markup += '</div>';//address
              markup += '</div>'; //
              markup += '<div class="mts col-xs-5 col-sm-4 font-size-small ">'; //sprites
              //markup += '<div class="pbs">' + '<span class="vam mrs iconx24-icons i-24-new-ratings-';
              if (point.gsRating != '') {
                  markup += '<div class="pbs"><div class="fl vam mrs gs-rating-sm ' + GS.rating.getRatingPerformanceLevel(point.gsRating) + '">';
                  markup += '<div>' + point.gsRating + '</div></div>' + mapPinRatingText() +  '</div>';
              }

              if(point.fitScore > 0){
                  if (point.strongFit){
                      markup += '<div class="pts">' + '<span class="vam mrs iconx24-icons i-24-strong-fit"></span>' + GS.I18n.t('strong_fit') + '</div>';
                  } else if (point.okFit){
                      markup += '<div class="pts">' + '<span class="vam mrs iconx24-icons i-24-ok-fit"></span>'+ GS.I18n.t('ok_fit')  + '</div>';
                  } else {
                      markup += '<div class="pts">' + '<span class="vam mrs iconx24-icons i-24-weak-fit"></span>' + GS.I18n.t('weak_fit') + '</div>';
                  }
              }
              markup += '</div>'; //sprites

              markup += '</div>'; //

              markup += '</div>'; //school data
              markup += '<hr class="mvm">';
              markup += '<div class="clearfix">';
              markup += '<div class="fl mrs">'; //stars
              if (point.numReviews > 0) {
                  markup += '<a href="' + point.reviewUrl + '">' + '<span class="vam">'+ mapPinCommunityStars(point.communityRatingStars) + '</span>';
                  markup += '<span class="mls font-size-small notranslate">'+ point.numReviews;
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
              markup += '<a class="clearfix" href="' + point.zillowUrl + '" rel="nofollow" target="_blank">';
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
          var mapPinCommunityStars = function(rating) { return $('.js-mapPinCommunityStars-' + rating).html() };

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
     return GS.widget.map;
    };

    var removeMapMarkerBySchoolId = function (schoolId) {
        _(GS.widget.mapMarkers).each( function (marker) {
            if (schoolId == marker.schoolId) {
                marker.setMap(null);
            }
        });
    };


    var addToInitDependencyCallbacks = function (func) {
        ajaxInitCallbacks.push(func);
        ajaxInitCallbacks = _.uniq(ajaxInitCallbacks);
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
        setHeightForMap: setHeightForMap,
        initAndShowMap : initAndShowMap,
        addToInitDependencyCallbacks: addToInitDependencyCallbacks,
        applyAjaxInitCallbacks: applyAjaxInitCallbacks,
        setAdditionalZoom: setAdditionalZoom
    }

})();
