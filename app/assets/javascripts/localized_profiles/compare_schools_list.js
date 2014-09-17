GS.compare = GS.compare || {};
GS.compare.schoolsList = GS.compare.schoolsList || (function() {
    var maxNumberOfSchools;
    var schools = []; //is an array of school objects {id, state, name, rating}
    var state = '';

    var addSchool = function(id, schoolsState, name, rating) {
        if (isSchoolInListsState(schoolsState) === false) {
            return false;
        }

        if (listContainsSchoolId(id) === true) {
            return false;
        }

        schools.push({
            id: parseInt(id),
            state: schoolsState.toLowerCase(),
            name: name,
            rating: rating.toString()
        });

        syncDataWithCookies();
        return true;
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
    };

    var removeSchool = function(id) {
        for (var i = 0; i < schools.length; i++ ) {
            if (schools[i]['id'] == parseInt(id)) {
                schools.splice(i, 1);
                syncDataWithCookies();
                return false;
            }
        }
    };

    var getSchoolIds = function() {
        var ids = [];
        for(var i = 0; i < schools.length; i++) {
            ids.push(schools[i]['id'])
        }
        return ids;
    };

    var listContainsSchoolId = function(id) {
        for (var i = 0; i < schools.length; i++ ) {
            if (schools[i]['id'] == parseInt(id)) {
                return true;
            }
        }
        return false;
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
        return false;
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
        getSchoolIds: getSchoolIds
    }

})();
