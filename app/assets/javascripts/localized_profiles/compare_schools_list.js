GS.compare = GS.compare || {};
GS.compare.schoolsList = GS.compare.schoolsList || (function() {
    var maxNumberOfSchools;
    var schools = []; //is an array of school objects {id, state, name, rating}
    var state = '';

    var addSchool = function(id, schoolsState, name, rating) {
        var responseObject = {
            success: true,
            errorCode: null //"wrongState"|"alreadyPresent"|"tooManySchools"|"exception"
        };
        if (isSchoolInListsState(schoolsState) === false) {
            responseObject['success'] = false;
            responseObject['errorCode'] = 'wrongState';
            return responseObject;
        }

        if (listContainsSchoolId(id) === true) {
            responseObject['success'] = false;
            responseObject['errorCode'] = 'alreadyPresent';
            return responseObject;
        }

        if (numberOfSchoolsInList() >= maxNumberOfSchools) {
            responseObject['success'] = false;
            responseObject['errorCode'] = 'tooManySchools';
            return responseObject;
        }

        schools.push({
            id: parseInt(id),
            state: schoolsState.toLowerCase(),
            name: name,
            rating: rating.toString()
        });

        syncDataWithCookies();
        return responseObject;
    };

    //checks to see if school is in same state as state variable. if state variable empty, it uses the schools state
    var isSchoolInListsState = function(schoolsState) {
        if (state === '' ) {
            state = schoolsState.toLowerCase();
            return true;
        } else {
            return state === schoolsState.toLowerCase();
        }
    };

    var syncDataWithCookies = function() {
        $.cookie('compareSchools', JSON.stringify(schools), {path:'/'});
//        GS.localStorage.setItem('compareSchools', schools);
    };

    var removeSchool = function(id) {
        for (var i = 0; i < schools.length; i++ ) {
            if (schools[i]['id'] == parseInt(id)) {
                schools.splice(i, 1);
                syncDataWithCookies();
                return true;
            }
        }
        return false;
    };

    var getSchoolIds = function() {
        var ids = [];
        for(var i = 0; i < schools.length; i++) {
            ids.push(schools[i]['id'])
        }
        return ids;
    };

    var listContainsSchoolId = function(id) {
        return getSchoolById(id) != null;
    };

    var getState = function() {
        return state
    };

    var numberOfSchoolsInList = function() {
        return schools.length;
    };

    var getSchoolById = function(id) {
        for (var i = 0; i < schools.length; i++ ) {
            if (schools[i]['id'] == parseInt(id)) {
                return schools[i];
            }
        }
        return null;
    };

    //grabs data from cookies and stores into schools and state variable
    var getDataFromCookies = function() {
        var schoolsFromCookie = $.cookie('compareSchools');
        if (typeof schoolsFromCookie === 'string') {
            schools = JSON.parse(schoolsFromCookie);
            if (schools.length > maxNumberOfSchools) {
                schools = [];
            }
            if (schools.length > 0) {
                state = schools[0]['state'].toLowerCase();
            }
        }
    };

    var buildCompareURL = function() {
        var schoolIds = getSchoolIds().join();
        var state = getState();
        return '/compare?state=' + state + '&school_ids=' + schoolIds;
    };

    //
    var init = function(maxNumOfSchools) {
        maxNumberOfSchools = maxNumOfSchools;
        getDataFromCookies();
    };

    return {
        init: init,
        addSchool: addSchool,
        removeSchool: removeSchool,
        numberOfSchoolsInList: numberOfSchoolsInList,
        getSchoolById: getSchoolById,
        listContainsSchoolId: listContainsSchoolId,
        getState: getState,
        getSchoolIds: getSchoolIds,
        buildCompareURL: buildCompareURL
    }

})();
