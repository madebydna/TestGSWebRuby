var GS = GS || {};

// Augments GS to add extra methods for getting school and state from URL
// Requires: Lo-Dash

(function(GS, _) {
    "use strict";
    var stateParam = 'state';
    var schoolIdParam = 'schoolId';

    var stateAbbreviationFromUrl = function() {
        var state = GS.uri.Uri.getFromQueryString(stateParam);

        if (state === undefined) {
            state = _(window.location.pathname.split('/')).filter(function(pathComponent) {
                return GS.states.isStateName(pathComponent);
            }).first();
        }

        return GS.states.abbreviation(state);
    };

    var schoolIdFromUrlPath = function() {
        var schoolId;
        var schoolPathRegex = /(\d+)-.+/;

        schoolId = _(window.location.pathname.split('/')).map(function(pathComponent) {
            var match = schoolPathRegex.exec(pathComponent);
            return (match === null) ? null : match[1];
        }).compact().first();

        schoolId = parseInt(schoolId);

        return isNaN(schoolId) ? undefined : schoolId;
    };

    var schoolIdFromUrl = function() {
        var schoolId = GS.uri.Uri.getFromQueryString(schoolIdParam);

        if (schoolId === undefined) {
            schoolId = schoolIdFromUrlPath();
        }

        schoolId = parseInt(schoolId);

        return isNaN(schoolId) ? undefined : schoolId;
    };


    GS.stateAbbreviationFromUrl = stateAbbreviationFromUrl;
    GS.schoolIdFromUrl = schoolIdFromUrl;

})(GS, _);