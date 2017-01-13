// TODO: import $
import BoundaryHelper from './boundary_helper';
import * as Geocoding from '../geocoding';

/**
 * BOUNDARIES CONSTRUCTOR DEFINITION
 * =================================
 */
function Boundaries(element, options){
  var element = element,
    options = options,
    markers,
    polygons,
    map,
    markers = new Array(),
    polygons = new Array(),
    focused;

  map = new google.maps.Map(element, options.map);

  google.maps.event.addListener(map, 'dragend', $.proxy(function(){this.trigger('dragend');}, this));
  google.maps.event.addListener(map, 'click', $.proxy(function(e){this.trigger('mapclick', e.latLng);}, this));

  this.getElement = function () { return element; }
  this.getMap = function () { return map; }
  this.getMarkers = function () { return markers; }
  this.getPolygons = function () { return polygons; }
  this.getOptions = function () { return options; }

  if (options.schools) {
    this.listen('focus', $.proxy(function (event, object ){
      if (object && object.data && object.data.type=='district'){
        this.schools(object.data);
      }
    }, this));
  }

  this.listen('dragend.boundaries', $.proxy(this.dragend, this));

  this.trigger('init');
}

Boundaries.prototype = {
  constructor: Boundaries

  , boundary: function (obj) {
    var found = false, deferred = new jQuery.Deferred();
    $.each(this.getPolygons(), $.proxy(function(index, value) {
      if ( value.key == obj.getKey() ){
        this.getPolygons()[index].setMap(this.getMap());
        found = true;
        obj.polygon = this.getPolygons()[index];
      } else {
        if (obj.getType()=='district' || (obj.getType()=='school' && value.type=='school')){
          this.getPolygons()[index].setMap(null);
        }
      }
    },this));
    if (!found) {
      var polygon = obj.getPolygon(this.getOptions().level);
      polygon.setMap(this.getMap());
      this.getPolygons().push(polygon);
    }
    deferred.resolve(obj);
    return deferred.promise();
  }

  , center: function (option) {
    if (this.exists(option) && option instanceof google.maps.LatLng ){
      this.getMap().setCenter(option);
    }
  }

  , district: function (option, districtId) {
    var deferred = new jQuery.Deferred()
      , id=(districtId)? districtId:(option && option.id)?option.id:''
      , state=(option && option.state)?option.state:(option && typeof option == 'string')?option:''
      , autozoom=(option && option.autozoom)?option.autozoom:false
      , lat=this.getMap().getCenter().lat()
      , lng=this.getMap().getCenter().lng()
      , level=this.getOptions().level;

    if (this.exists(option) && id==''){
      lat = option.lat();
      lng = option.lng();
    }

    var success = function (districts) {
      if (districts && districts.length>0){
        this.show(districts[0]);
        this.trigger('load', districts[0]);
        this.focus(districts[0]);
      }
      deferred.resolve(districts);
    }

    if (id!='')
      BoundaryHelper.getDistrictById(state, id)
      .done($.proxy(success, this))
      .done($.proxy(function(districts){
        if (districts && districts.length && districts.length>0 && autozoom){
          this.autozoom(districts[0]);
        }
      }, this))
      .done($.proxy(function(districts){
        if (districts && districts.length && districts.length>0){
          var coord = new google.maps.LatLng(districts[0].lat, districts[0].lon);
          this.districts(coord);
        }
      }, this))
      .fail(function(){deferred.reject();});
    else
      BoundaryHelper.getDistrictsForLocation(lat, lng, level)
      .done($.proxy(success, this)).fail(function(){deferred.reject();});

    return deferred.promise();
  }

  , priv: function (option) {
    var deferred = new jQuery.Deferred()
      , lat=this.getMap().getCenter().lat()
      , lng=this.getMap().getCenter().lng()
      , level=this.getOptions().level;
    if (this.exists(option) && option.lat() && option.lng()){
      lat = option.lat(), lng = option.lng();
    }
    var success = function(schools) {
      for (var i=0; i<schools.length; i++) {
        schools[i].charterOnly = false;
        this.show(schools[i]);
      }
      deferred.resolve(schools);
    }

    BoundaryHelper.getNonDistrictSchoolsNearLocation(lat, lng, level, 'private')
      .done($.proxy(success, this)).fail(function(){deferred.reject();});

    return deferred.promise();
  }

  , charter: function (option) {
    var deferred = new jQuery.Deferred()
      , lat=this.getMap().getCenter().lat()
      , lng=this.getMap().getCenter().lng()
      , level=this.getOptions().level;
    if (this.exists(option) && option.lat() && option.lng()){
      lat = option.lat(), lng = option.lng();
    }
    var success = function(schools) {
      for (var i=0; i<schools.length; i++) {
        schools[i].charterOnly = true;
        this.show(schools[i]);
      }
      deferred.resolve(schools);
    }

    BoundaryHelper.getNonDistrictSchoolsNearLocation(lat, lng, level, 'charter')
      .done($.proxy(success, this)).fail(function(){deferred.reject();});

    return deferred.promise();
  }

  , districts: function (option) {
    var deferred = new jQuery.Deferred()
      , lat = this.getMap().getCenter().lat()
      , lng = this.getMap().getCenter().lng()
      , level = this.getOptions().level;
    if (this.exists(option) && option.lat() && option.lng()){
      lat = option.lat(), lng = option.lng();
    }
    var success = function (districts){
      for(var i=0; i<districts.length; i++) {
        this.show(districts[i]);
      }
      this.autozoom(districts);
      this.trigger('load', districts);
      deferred.resolve(districts);
    }

    BoundaryHelper.getDistrictsNearLocation(lat, lng, level)
      .done($.proxy(success, this)).fail(function(){deferred.reject()});
    return deferred.promise();
  }

  , focus: function (obj) {

    var districtKey = null;
    if (obj.getType()=='district'){
      this.hide('school');
    } else {
      districtKey = 'district-' + obj.state + '-' +obj.districtId;
    }

    this.shown(function(markers){
      for (var i=0; i<markers.length; i++) {
        if (markers[i].key == obj.getKey() || (districtKey && districtKey==markers[i].key)){
          markers[i].setZIndex(5);
        } else if(markers[i].getZIndex() > 3) {
          markers[i].setZIndex((markers[i].type=='school')?2:3);
        }
      }
    });
    this.boundary(obj);
    this.info(obj);
    this.trigger('focus', obj);
  }

  , geocode: function (option) {
    Geocoding.geocode(option).done(
      $.proxy(function (data) {
        this.center(new google.maps.LatLng(data[0].lat, data[0].lon));
        if (this.getOptions().centerMarker){
          this.getOptions().centerMarker.setMap(this.getMap());
          this.getOptions().centerMarker.setPosition(new google.maps.LatLng(data[0].lat, data[0].lon));
        }
        this.refresh();
        this.trigger('geocode', data);
      }, this)
    ).fail(
      $.proxy(function(){
        this.trigger('geocodefail');
      }, this)
    );
  }

  , geocodereverse: function ( option ) {
    $.when(Geocoding.geocodeReverse(option.lat(), option.lng()))
      .then ($.proxy(function (data) {
        this.trigger('geocodereverse', data);
      }, this));
  }

  , info: function (obj) {
    if ( !this.getOptions().infoWindow ) return;
    if ( !this.infoWindow ) {
      this.infoWindow = new InfoBox({
        disableAutoPan: false,
        maxWidth: 0,
        pixelOffset: new google.maps.Size(-150, -45),
        zIndex: 99,
        boxStyle: {
          opacity: 1,
          width: "300px"
        },
        closeBoxMargin: "8px 8px 8px 8px",
        closeBoxURL: "/assets/icons/google_map_pins/16x16_close.png",
        infoBoxClearance: new google.maps.Size(1, 1),
        isHidden: false,
        pane: "floatPane",
        alignBottom:true,
        enableEventPropagation: false
      });
    }
    this.infoWindow.setContent('');
    this.infoWindow.close();
    if (this.getOptions().infoWindow) this.infoWindow.setContent(this.getOptions().infoWindow(obj));

    for (var i=0; i<this.getMarkers().length; i++) {
      if (this.getMarkers()[i].key==obj.getKey()){
        this.infoWindow.open(this.getMap(), this.getMarkers()[i]);
        this.trigger('info', obj);
        return;
      }
    }
  }

  , hide: function(type) {

    for (var i=0; i<this.getMarkers().length; i++) {
      var title = this.getMarkers()[i].key
        , marker = this.getMarkers()[i]
        , school = marker.school
        , district = marker.district
        , hide = false;

      if (type=='private' || type=='charter'){
        if (school && type=='private' && school.schoolType=='private') {
          hide = true;
        }
        else if (school && type=='charter' && school.schoolType=='charter' && school.charterOnly) {
          hide = true;
        }
      }
      else if (type=='district') {
        if (district){
          hide = true;
        }
      }
      else if (type=='school') {
        if (school){
          if (school.schoolType=='charter'){
            if (school.districtId) {
              hide = true;
            } else {
              hide = false;
            }
          }
          else if (school.schoolType=='private'){
            hide = false;
          }
          else {
            hide = true;
          }
        }
      }

      if (hide) {this.getMarkers()[i].setMap(null);}
    }
    for (var i=0; i<this.getPolygons().length; i++) {
      if (this.getPolygons()[i].type==type){
        this.getPolygons()[i].setMap(null);
      }
    }
  }

  , level: function ( option ) {
    this.getOptions().level = option;
    this.refresh();
  }

  , listen: function (event, func) {
    $(this.getElement()).on(event+'.boundaries', func);
  }

  , pin: function (obj) {
    var found = false;
    for (var i=0; i<this.getMarkers().length; i++) {
      if (this.getMarkers()[i].key == obj.getKey()){
        this.getMarkers()[i].setMap(this.getMap());
        found = true;
      }
    }
    if (!found) {
      var module = this, marker = obj.getMarker();
      if (obj.getType()=='school') marker.school = obj;
      else marker.district = obj;
      marker.key = obj.getKey();
      marker.setZIndex((obj.getType()=='school')?2:3);
      google.maps.event.clearListeners(marker, 'click');
      google.maps.event.addListener(marker, 'click', $.proxy(function(){
        module.focus(this);
        module.trigger('markerclick', this);
      }, obj));
      marker.setMap(this.getMap());
      this.getMarkers().push(marker);
    }
  }

  , refresh: function() {
    if (this.infoWindow) this.infoWindow.close();
    this.hide('school');
    this.hide('district');
    this.center(this.getMap().getCenter());
  }

  , school: function (option) {
    var deferred = new jQuery.Deferred()
      , lat = this.getMap().getCenter().lat()
      , lng = this.getMap().getCenter().lng()
      , level = this.getOptions().level;
    if (this.exists(option) && option.lat && option.lng) {
      lat = option.lat(), lng = option.lng();
    }
    var success = function (schools) {

      for (var i=0; i<schools.length; i++) {
        this.show(schools[i]);
        this.focus(schools[i]);
      }
      deferred.resolve(schools);
      this.trigger('load', schools);
    }

    // load a specific school
    if (this.exists(option) && option.id && option.state ){
      BoundaryHelper.getSchoolById(option.id, option.state, this.getOptions().level)
        .done($.proxy(success, this))
        .done($.proxy(function(schools){
          if (schools && schools.length>0){
            var school = schools[0];
            this.districts(new google.maps.LatLng(school.lat, school.lon));
            $.when(this.district({state: option.state, id: schools[0].districtId, autozoom: false}))
              .always($.proxy(function(){
                this.focus(school);
                this.autozoom(school);
              },this));
          }
        }, this))
        .fail(function(){
          deferred.reject();
        });
    }
    // otherwise load a school by id
    else {
      BoundaryHelper.getSchoolByLocation(lat, lng, level)
        .done($.proxy(success, this)).fail(function(){
          deferred.reject();
        });
    }

    return deferred.promise();
  }

  /**
   * We should show the school boundary for center
   * on the map and also show that schools district
   * boundary if it is loaded on the map.
   */
    , school_with_district:  function (option) {
        var success = function (schools) {
            var school = (schools && schools.length>0) ? schools[0]:null;
            $.when(this.districts(option)).then($.proxy(function(districts){
                for (var i=0; i<districts.length; i++) {
                    this.show(districts[i]);
                }
                if (school){
                    var found = false;
                    for (var i=0; i<districts.length; i++) {
                        var id = (districts[i].id==school.districtId);
                        var state = (districts[i].state==school.state);
                        if (id && state) {
                            this.focus(districts[i]);
                            this.focus(school);
                            found = true;
                            break;
                        }
                    }
                    if (!found && school.districtId && school.state ) {
                        $.when(this.district(school.state, school.districtId)).then($.proxy(function(){
                            this.focus(school);
                        },this));
                    }
                }
                else {
                    this.district(option);
                }
            }, this));
        }
        if (option && option.lat) this.center(option);
        this.school(option).always($.proxy(success, this));
    }

    , schools: function () {
        if (arguments.length) {
            var district = arguments[0];
            $.when(BoundaryHelper.getSchoolsForDistrict(district.id, district.state, this.getOptions().level))
                .then($.proxy(function(schools){
                for (var i=0; i<schools.length; i++) {
                    this.show(schools[i]);
                }
                this.trigger('load', schools);
            }, this));
        }
    }

  , show: function ( obj ) {
    this.pin(obj);
  }

  , shown: function (callback) {
    var shown = new Array();
    for (var i=0; i<this.getMarkers().length; i++) {
      if (this.exists(this.getMarkers()[i]) && this.exists(this.getMarkers()[i].getMap())){
        shown.push(this.getMarkers()[i]);
      }
    }
    return (this.exists(callback)) ? callback(shown) : shown ;
  }

  , trigger: function (event, data) {
    var e = jQuery.Event(event);
    if (event == 'focus') {
      $(this.getElement()).triggerHandler(e, {data: data});
    } else {
      $(this.getElement()).trigger(e, {data: data});
    }
  }

  , dragend: function () {
    var bounds = this.getMap().getBounds();
    for (var i=0; i<this.getMarkers().length; i++) {
      if (this.getMarkers()[i].getMap()!=null && bounds.contains(this.getMarkers()[i].getPosition())){
        this.trigger('inbounds');
        return;
      }
    }
    this.trigger('outbounds');
  }

  , autozoom: function (option) {
    if (this.exists(option)) {
      if (option.type && option.type=='district'){
        this.getMap().fitBounds(option.getPolygon().getBounds());
      }
      else if (option.type && option.type=='school') {
        this.getMap().fitBounds(option.getPolygon().getBounds());
      }
    }

    if (this.getOptions().autozoom) {
      this.shown($.proxy(function(markers){
        var bounds = new google.maps.LatLngBounds();
        for (var i=0; i<markers.length; i++) {
          bounds.extend(markers[i].getPosition());
        }
        this.getMap().fitBounds(bounds);
      }, this));
    }
  }

  , exists: function (obj){
    return typeof obj !== "undefined" && obj !== null;
  }
};

function init() {
  /**
   * BOUNDARIES JQUERY PLUGIN DEFINITION
   * ===================================
   */
  $.fn.boundaries = function (option, params) {
    return this.each(function(){
      var $this = $(this),
        options = $.extend(
          {},
          $.fn.boundaries.defaults,
          $this.data(),
          (typeof option =='object' && option)
        ),
        data = $this.data('boundaries');

      if (!data) {
        data = new Boundaries(this, options);
        $this.data('boundaries', data);
      }
      if (typeof option == 'string') {
        data[option](params);
      }
    });
  }

  /**
   * BOUNDARIES JQUERY DEFAULTS
   * ===================================
   */
  $.fn.boundaries.defaults = {
    level: 'e',
    schools: true,
    autozoom: false,
    centerMarker: new google.maps.Marker({
      icon:new google.maps.MarkerImage(
        '/res/img/map/green_arrow.png',
        new google.maps.Size(39,34),
        new google.maps.Point(0,0),
        new google.maps.Point(11,34)
      ),
      shape:{type:'poly', coord:[0, 0, 23, 0, 23, 34, 0, 34]},
      shadow:new google.maps.MarkerImage('/res/img/map/green_arrow_shadow.png', new google.maps.Size(39,34), null, new google.maps.Point(11, 34))
    }),
    map: {
      center: new google.maps.LatLng(37.77,-122.419),
      zoom: 11,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    },
    infoWindow: function(obj){}
  };

}

export { init };

