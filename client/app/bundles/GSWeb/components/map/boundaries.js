const Boundary = (function (){

  // state management
  var State = function (name) {
    this.name = name;
    this.position = new google.maps.LatLng(0,0);
    this.current = false;
    this.autozoomed = false;
  }
  State.prototype = {
    constructor: State
  }
  var STATES = {
    browsing: new State("browsing"),
    searching: new State("searching")
  };

  var $map,
    $dropdown,
    $header,
    $list,
    $level,
    $search,
    $priv,
    $charter,
    $nearby,
    $districtNameHeader,
    currentLevel = 'e',
    currentZip,
    currentLat,
    currentLng;

  // selected hold the currently selected district id, geocoding is boolean for when geocode
  // request is made, and geocoded is the district selected after geocoding.
  // This is used for determining if we should run district_with_school or not
  var selected, geocoding, geocoded;

  var init = function (_$map, dropdown, header, list, level, search, priv, charter, nearby, districtNameHeader ) {

      $map = _$map;
      $dropdown = $(dropdown),
      $header = $(header),
      $list = $(list),
      $level = $(level),
      $priv = $(priv),
      $charter = $(charter),
      $search = $(search),
      $nearby = $(nearby),
      $districtNameHeader = $(districtNameHeader);

    enter('browsing');

    events();

    var params = getUrlParams()
      , paramsSet = (params.lat && params.lon)
      , level = (params.level && (params.level == 'e' || params.level=='m' || params.level=='h')) ? params.level : 'e'
      , schoolId = params.schoolId ? params.schoolId : ''
      , districtId = params.districtId ? params.districtId : ''
      , state = params.state ? params.state : ''
      , q = params.q ? params.q : '';

    if (q!='') {
      $search.find('#js_mapAddressQuery').val(q);
      $districtNameHeader.html('Districts near ' + q);
    }


    var options = {type:'districts', infoWindow: infoWindowMarkupCallback, autozoom: false, level: level};
    $map.boundaries(options);

    // if (schoolId && state) {
    //   $map.boundaries('school', {id: schoolId, state: state});
    // }

    // if (!schoolId && districtId) {
    //   $map.boundaries('district', {state: state, id: districtId, autozoom: true});
    // }

    // $dropdown.html('');
    // $dropdown.append($('<option></option>').html('Select a district'));

    // if (params.address)
    //   search(params.address);

    if (paramsSet){
      enter('searching');
      currentLat = params.lat, currentLng = params.lon;
      STATES.searching.position = new google.maps.LatLng(params.lat, params.lon);
      $map.boundaries('school_with_district',STATES.searching.position);
    }
    return $map;
  }

  var events = function () {
    $map.on('focus.boundaries', $.proxy(focusOnDistrict, this));
    $map.on('focus.boundaries', $.proxy(focusOnSchool, this));
    $map.on('geocode.boundaries', $.proxy(geocode, this));
    $map.on('geocodefail.boundaries', $.proxy(failed, this));
    $map.on('init.boundaries', $.proxy(showall, this));
    $map.on('load.boundaries', $.proxy(load, this));
    // $map.on('inbounds.boundaries', $.proxy(inbounds, this));
    // $map.on('outbounds.boundaries', $.proxy(outbounds, this));
    // $map.on('mapclick.boundaries', $.proxy(mapclick, this));
    // $map.on('markerclick.boundaries', $.proxy(markerclick, this));

    // $dropdown.on('change', $.proxy(dropdown, this));
    $level.on('change', level);
    $search.on('submit', search);

    $priv.on('click', priv);
    $charter.on('click', charter);
  }

  // var dropdown = function (e) {
  //   var option = $dropdown.find('option:selected');
  //   if (option.length) {
  //     var district = $(option[0]).data('district');
  //     if (state('searching') && district.id != STATES.searching.originalId){
  //       enter('browsing');
  //     }
  //     STATES.browsing.position = new google.maps.LatLng(district.lat, district.lon);
  //     $map.boundaries('focus', district);
  //   }
  // }

  var level = function (e) {
    $map.boundaries('level', $(this).val());
    $list.html('');
    if (state('searching')){
      history(STATES.searching.position.lat(), STATES.searching.position.lng(), $(this).val());
      $map.boundaries('school_with_district', STATES.searching.position);
    }
    else {
      history(STATES.browsing.position.lat(), STATES.browsing.position.lng(), $(this).val());
      $map.boundaries('district', STATES.browsing.position);
      $map.boundaries('districts', STATES.browsing.position);
    }

    priv();
    charter();
  }

  var load = function (e, obj) {
    if (typeof obj == 'object' && obj.data ) {
      if (obj.data.length) {
        if (obj.data[0].type=='school') {
          // updateSchoolList(obj.data);
        } else {
          // districts(e, obj);
        }
      }
      else if (obj.data.getType && obj.data.getType()=='district') {
        // addDropdownItem(obj.data);
        // $dropdown.val(obj.data.getKey());
      }
    }
  }

  // perform a search
  var search = function (e) {
    if (typeof e == 'string') $search.find('#js_mapAddressQuery').val(e);
    else e.preventDefault();
    enter('searching');
    $map.boundaries('geocode', $search.find('#js_mapAddressQuery').val());
  };

  // show all the components
  var showall = function () {
    $('.js_showWithMap').show();
  }

  // boolean to test current state
  var state = function (option) {
    for (var key in STATES){
      if (STATES[key].name==option)
        return STATES[key].current;
    }
    return false;
  }

  // district brought into focus
  var focusOnDistrict = function (e, obj) {
    if (obj && obj.data && obj.data.type == 'district'){
      if (state('searching') && !STATES.searching.originalId){
        STATES.searching.originalId = obj.data.id;
        if (!STATES.searching.autozoomed) {
          $map.boundaries('autozoom', obj.data);
          STATES.searching.autozoomed=true;
        }
      }
      else if (state('browsing')){
        if (!STATES.browsing.autozoomed){
          $map.boundaries('autozoom', obj.data);
          STATES.browsing.autozoomed=true;
        }
      }
      STATES.browsing.position = new google.maps.LatLng(obj.data.lat, obj.data.lon);
      $dropdown.val(obj.data.getKey());
      updateDistrictHeader(obj.data);
      nearbyhomes(obj.data);
      priv();
      charter();
    }
  }

  var nearbyhomes = function (data) {
    if (data && data.address && data.address.zip) {
      $nearby.show().removeClass('dn');
      $nearby.find('a').attr('href', 'http://www.zillow.com/'+data.state+'-'+data.address.zip.split("-")[0]+'?utm_source=GreatSchools&utm_medium=referral&utm_campaign=districtbrowsemap&cbpartner=Great+Schools');
    }
  }

  // school brought into focus
  var focusOnSchool = function (e, obj) {
    if (obj && obj.data && obj.data.type=='school'){
      if (state('searching') && !STATES.searching.originalId){
        if (!STATES.searching.autozoomed) {
          $map.boundaries('autozoom', obj.data);
          STATES.searching.autozoomed=true;
        }
      }
      $('.js-listItem').removeClass('selected');
      var $this = $('.js-listItem[id=' + obj.data.getKey() + ']');
      if ($this && $this.position()) {
        $this.addClass('selected');

        // position should be between 0 and height.
        // parentElem must be relatively positioned!
        var elemTop = $this.position().top;
        var isScrolledIntoView = elemTop > 0 && elemTop < $('#schoolListDiv').height();

        if ($this.position() != null && isScrolledIntoView === false) {
          var scrollTop = $('#schoolListDiv').scrollTop();
          $('#schoolListDiv').scrollTop(scrollTop + $this.position().top);
        }
      }
    }
  }

  var failed = function ( event, obj ) {
    var val = $('#js_mapAddressQuery').val();
    alert('\"' + val + '\" could not be found.  Please try a different search.');
  }

  var clear = function () {
    $districtNameHeader.html('District name');
    $map.boundaries('refresh');
    $dropdown.html('').append('<option>Select a district</option>');
    $list.html('');
    $header.addClass('dn');
  }

  var geocode = function (e,obj) {
    if (obj.data.length>0){
      clear();
      $districtNameHeader.html('Districts near ' + obj.data[0].normalizedAddress);
      history(obj.data[0].lat, obj.data[0].lon, currentLevel);
      STATES.searching.position = new google.maps.LatLng(obj.data[0].lat, obj.data[0].lon);
      $map.boundaries('school_with_district', STATES.searching.position);
      priv();
      charter();
    }
  }

  var history = function (lat, lng, level) {
    var q = $search.find('#js_mapAddressQuery').val();
    if (q.indexOf('Enter an address')>=0) {
      q = '';
    }
    var params = '?lat='+lat+'&lon='+lng+'&level='+level+'&q='+q;
    if (typeof(window.History) !== 'undefined' && window.History.enabled === true) {
      window.History.replaceState(null, document.title, params);
    } else {
      window.location = window.location.pathname + '' + params;
    }
  }

  var enter = function (state) {
    for (var key in STATES) {
      if (STATES[key].name == state) {
        STATES[key].originalId = null;
        STATES[key].current = true;
        STATES[key].autozoomed = false;
      }
      else
        STATES[key].current = false;
    }
  }

  var charter = function (e) {
    $map.boundaries('hide', 'charter');
    if ($charter.prop('checked')){
      var position = (state('searching') ? STATES.searching.position : STATES.browsing.position);
      $map.boundaries('charter', position);
    }
  }

  var priv = function (e) {
    $map.boundaries('hide', 'private');
    if ($priv.prop('checked')){
      var position = (state('searching') ? STATES.searching.position : STATES.browsing.position);
      $map.boundaries('priv', position);
    }
  }

  var infoWindowMarkupCallback = function ( obj ) {
    var id = (obj.type=='school') ? '#boundaryMapSchoolInfoWindow' : '#boundaryMapDistrictInfoWindow'
      , $element = $(id).clone()
      , $link = $('<a></a>').attr('href', obj.url).html(obj.name)
      , $rating = $('<span class="sprite badge_sm_na"></span>')
      , $homes = $($element.find('.js_homesforsale'))
      , $wrapper = $('<div class="mod standard_5-1 mbm"></div>')
      , address = '';

    if ( obj.rating > 0 && obj.rating < 11) $rating.removeClass('badge_sm_na').addClass('badge_sm_' + obj.rating);
    if ( obj.type=='school'){
      if (obj.address.street1) address += obj.address.street1 + '<br/>';
      if (obj.address.cityStateZip) address += obj.address.cityStateZip;
      (obj.address.zip) ?
        $homes.show().find('a').attr('href', 'http://www.zillow.com/'+obj.state+'-'+obj.address.zip.split("-")[0]+'?utm_source=GreatSchools&utm_medium=referral&utm_campaign=districtbrowsemap&cbpartner=Great+Schools').attr('target', '_blank') :
        $homes.hide();


    }
    else if (obj.type == 'district'){
      var array = new Array();
      if (obj.elementary){
        array.push('Elementary (' + obj.elementary + ')');
      } else {
        array.push('Elementary (0)');
      }
      if (obj.middle) {
        array.push('Middle (' + obj.middle + ')');
      } else {
        array.push('Middle (0)');
      }
      if (obj.high){
        array.push('High (' + obj.high + ')');
      } else {
        array.push('High (0)');
      }

      if (array.length) {
        address = array.join(', ');
      }
    }
    $element.find('.js_name').html($link);
    $element.find('.js_rating').html($rating);
    $element.find('.js_address').html(address);
    if (obj.type=='school') {
      var $comments = $element.find('.js_comments');
      $wrapper.removeClass("mbm");
      $comments.html('');
      if (!obj.isPolygonShown() && (obj.schoolType!='private' && !obj.charterOnly)) $comments.html('<div class="ft smaller bottom"><div class="media attribution"><div class="img mrm"><span class="iconx16 i-16-information"><!-- do not collapse --></span></div><div class="bd">Contact school district for school boundaries</div></div></div>');
      if (obj.schoolType=='private') $comments.append('<div class="ft smaller bottom"><div class="media attribution"><div class="img"><span class="iconx16 i-16-information"><!-- do not collapse --></span></div><div class="bd">Private schools are not in the district.</div></div></div>');
      if (obj.schoolType=='charter' && obj.charterOnly)
        $comments.append('<div class="ft smaller bottom"><div class="media attribution"><div class="img"><span class="iconx16 i-16-information"><!-- do not collapse --></span></div><div class="bd">Charter schools are not in the district.</div></div></div>');
    }
    $wrapper.append($element);
    return $('<div></div>').append($wrapper).html();
  };

  // var updateSchoolList = function ( schools ){
  //   var ratingBase = "i-24-ratings";
  //   $list.empty();
  //   var itemTemplate = '<div class="js-listItem media skin-1 attribution pvs phm" style="border-bottom: 1px solid #f1f1f1"></div>'
  //     , spriteTemplate = '<span class="img mrm"><!-- do not collapse --></span>'
  //     , nameTemplate = '<div class="small bottom bd" id=""></div>'
  //     , htmlString = '';
  //   schools.sort(sort);
  //   for (var i = 0; i < schools.length; i++) {
  //     var school = schools[i]
  //       , schoolRating = 'na'
  //       , $name = $(nameTemplate)
  //       , $sprite = $(spriteTemplate)
  //       , badge = (school.rating > 0 && school.rating < 11) ? school.rating : 'NA';
  //     if (school.schoolType!='private' && !(school.schoolType=='charter' && !school.districtId)){
  //       var spriteClass = school.isNewGSRating===true ? 'ratingx24-public-RYG r-24-' : 'ratingx24-public-RYG r-24-';
  //       $sprite.addClass(spriteClass + badge);
  //       $name.append(school.name);
  //       var $listItem = $(itemTemplate).attr('id',school.getKey()).append($sprite).append($name).attr('id', school.getKey());
  //       $listItem.data('school', school);
  //       $listItem.on('click', function(){
  //         $('.js-listItem').removeClass('selected');
  //         $(this).addClass('selected').removeClass('list-over');
  //         var val = $(this).data('school');
  //         $map.boundaries('focus', val);
  //       });
  //       $listItem.hover(function(){
  //         if(!$listItem.hasClass('selected')){
  //           $(this).addClass('list-over');
  //         }
  //       },
  //         function(){
  //           if(!$listItem.hasClass('selected')){
  //             $(this).removeClass('list-over');
  //           }
  //         });
  //       $list.append($listItem);
  //     }
  //   }
  //   (schools.length>0) ? $('#schoolListWrapper').show():$('#schoolListWrapper').hide();
  // }

  // var alpha = function (a, b) {
  //   return (a.name.toUpperCase() < b.name.toUpperCase()) ? -1 : (a.name.toUpperCase() > b.name.toUpperCase()) ? 1 : 0;
  // }

  // var sort = function (a, b) {
  //   if (a.rating && b.rating) {
  //     if (a.rating == b.rating) {
  //       if (a.name == b.name) return 0;
  //       return (a.name < b.name) ? -1 : 1;
  //     }
  //     return (a.rating < b.rating) ? 1 : -1;
  //   }
  //   if (a.rating && !b.rating) {
  //     return -1;
  //   }
  //   return 1;
  // }

  // var addDropdownItem = function(district) {
  //   var $option = $dropdown.find("option[value='" + district.getKey() + "']");
  //   if ($option.length==0) {
  //     var $option = $('<option></option>').val(district.getKey());
  //     $option.data('district', district);
  //     $dropdown.append($option.html(district.name));
  //   }
  // }

  // var districts = function (event, obj) {
  //   var curr = $dropdown.val();
  //   $dropdown.html('');
  //   obj.data.sort(alpha);
  //   $dropdown.append($('<option></option>').html('Select a district'));
  //   for( var i=0; i<obj.data.length; i++) {
  //     addDropdownItem(obj.data[i]);
  //   }
  //   if (curr) $dropdown.val(curr);
  // };

  // var mapclick = function ( event, obj ){
  //   enter('browsing');
  //   STATES.browsing.position = obj.data;
  //   $map.boundaries('district', obj.data);
  //   $map.boundaries('districts', obj.data);
  // }

  // var markerclick = function( event, obj) {
  //   if (state('searching') && obj.data.type=='district' && STATES.searching.originalId!=obj.data.id){
  //     enter('browsing');
  //   }
  //   STATES.browsing.position = obj.data.getMarker().getPosition();
  // }

  // var updateDistrictHeader = function( district ){
  //   $header.removeClass('dn');
  //   if (district.rating>0 && district.rating<11){
  //     $header.find('#ratings-test').html(district.rating);
  //     $header.find('#ratings-test').removeClass('square-large-grey');
  //     $header.find('#ratings-test').addClass('square-large');
  //   } else {
  //     $header.find('#ratings-test').html('NR');
  //     $header.find('#ratings-test').removeClass('square-large');
  //     $header.find('#ratings-test').addClass('square-large-grey');
  //   }
  //   $header.find('#school-name-test').html(district.name);
  // };


  var getUrlParams = function(){
    var urlParams = {};
    var e,
      a = /\+/g,  // Regex for replacing addition symbol with a space
      r = /([^&=]+)=?([^&]*)/g,
      d = function (s) { return decodeURIComponent(s.replace(a, " ")); },
      q = window.location.search.substring(1);

    while (e = r.exec(q))
      urlParams[d(e[1])] = d(e[2]);

    return urlParams;
  };

  return {
    init: init,
    getUrlParams: getUrlParams
  }
});

export default Boundary;
