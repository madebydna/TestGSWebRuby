//TODO: import $
import School from './school';
import District from './school';
import Mappable from './mappable';

/**
 * BOUNDARY HELPER
 * ===============
 */
const BoundaryHelper = (function($){

    var getDistrictById = function (state, id) {
        var deferred = new jQuery.Deferred();
        var request = $.ajax({
            url: '/gsr/api/districts',
            cache: true,
            data: {state: state, id: id },
            success:districtSuccess,
            fail: fail,
            context: deferred
        })
        return deferred.promise();
    }

    var getDistrictsNearLocation = function(lat, lon, level) {
        var deferred = new jQuery.Deferred();
        // var request = $.ajax({
        //     url: '/geo/boundary/ajax/getDistrictsNearLocation.json',
        //     cache: true,
        //     data: {lat: lat, lon: lon, level: level},
        //     type: 'GET',
        //     dataType: 'json',
        //     success: districtSuccess,
        //     fail: fail,
        //     context: deferred
        // });
        return deferred.promise();
    };

    var getDistrictsForLocation = function (lat, lon, level) {
        var deferred = new jQuery.Deferred();
        var request = $.ajax({
            url:'/geo/boundary/ajax/getDistrictsForLocation.json',
            cache: true,
            data: {lat: lat, lon: lon, level: level},
            type: 'GET',
            dataType: 'json',
            success: districtSuccess,
            fail: fail,
            context: deferred
        });
        return deferred.promise();
    };

    var getNonDistrictSchoolsNearLocation = function (lat, lon, level, type) {
        var deferred = new jQuery.Deferred();
        var urlType = (type=='charter') ? 'Charter' : 'Private';
        $.ajax({
            url: '/geo/boundary/ajax/get' + urlType + 'SchoolsNearLocation.json',
            data: {lat: lat, lon: lon, level: level},
            cache: true,
            type: 'GET',
            dataType: 'json',
            success: schoolSuccess,
            fail: fail,
            context: deferred
        });
        return deferred.promise();
    };

    var getSchoolsForDistrict = function ( id, state, level ) {
        var deferred = new jQuery.Deferred();
        $.ajax({
            url: '/geo/boundary/ajax/getSchoolsByDistrictId.json',
            data: {id: id, state: state, level: level},
            cache: true,
            type: 'GET',
            dataType: 'json',
            success: schoolSuccess,
            fail: fail,
            context: deferred
        });
        return deferred.promise();
    }

    var getSchoolByLocation = function ( lat, lng, level ) {
        var deferred = new jQuery.Deferred();
        $.ajax({
            url: '/geo/boundary/ajax/getSchoolByLocation.json',
            data: {lat: lat, lon: lng, level: level},
            cache: true,
            type: 'GET',
            dataType: 'json',
            success: schoolSuccess,
            timeout: 6000,
            context: deferred
        }).fail($.proxy(fail, deferred));
        return deferred.promise();
    }

    var getSchoolById = function ( id, state, level ) {
        var deferred = new jQuery.Deferred();
        $.ajax({
            url: '/gsr/api/schools',
            data: {id: id, state: state, level: level, extras: 'boundaries'},
            cache: true,
            type: 'GET',
            dataType: 'json',
            success: schoolSuccess,
            timeout: 6000,
            context: deferred
        }).fail($.proxy(fail, deferred));
        return deferred.promise();
    }

    var schoolSuccess = function (data) {
        var schools = new Array();
        if (data.items && data.items.length) {
            for (var i=0; i<data.items.length; i++) {
                schools.push(new School(data.items[i]));
            }
        }
        this.resolve(schools);
    }

    var districtSuccess = function (data) {
        var districts = new Array();
        if ( data.districts && data.districts.length ) {
            for (var i=0; i< data.districts.length; i++) {
                districts.push(new District(data.districts[i]));
            }
        }
        this.resolve(districts);
    };

    var fail = function () {
        this.reject();
    }

    Array.prototype.contains = function(obj) {
        var i = this.length;
        while (i--) {
            if (this[i] === obj) {
                return true;
            }
        }
        return false;
    };

    var geocodeReverse = function (lat, lng) {
        var deferred = new jQuery.Deferred();
        var geocoder = new google.maps.Geocoder();
        if (geocoder && lat && lng) {
            geocoder.geocode({location: new google.maps.LatLng(lat, lng)}, function (results, status) {
                if (status=='OK'){
                    var GS_geocodeResults = new Array();
                    for (var i=0; i<results.length; i++) {
                        var result = {};
                        result.lat = results[i].geometry.location.lat();
                        result.lon = results[i].geometry.location.lng();
                        result.normalizedAddress = results[i].formatted_address;
                        for (var x=0; x<results[i].address_components.length; x++) {
                            if (results[i].address_components[x].types.contains('postal_code')){
                                result.zip = results[i].address_components[x].long_name;
                            }
                        }
                        GS_geocodeResults.push(result);
                    }
                    deferred.resolve(GS_geocodeResults);
                } else {
                    deferred.reject();
                }
            });
        } else {
            deferred.reject();
        }
        return deferred.promise();
    };


    return {
        getDistrictsNearLocation: getDistrictsNearLocation,
        getDistrictsForLocation: getDistrictsForLocation,
        getDistrictById: getDistrictById,
        getSchoolsForDistrict: getSchoolsForDistrict,
        getSchoolById: getSchoolById,
        getSchoolByLocation: getSchoolByLocation,
        getNonDistrictSchoolsNearLocation: getNonDistrictSchoolsNearLocation
    }
}(window.jQuery));

export default BoundaryHelper;
