// Augments GS to add extra methods for getting school and state from URL
// Requires: Lo-Dash

(function(GS, _) {
    "use strict";
    var stateParam = 'state';
    var schoolIdParam = 'schoolId';

    var spacesToHyphens = function(str) {
        return str.replace(/ /g, '-');
    };

    var hyphensToSpaces = function(str) {
        if (!_.isString(str)) {
            return;
        }

        return str.replace(/-/g, ' ');
    };

    var stateAbbreviationFromUrl = function() {
        var state = GS.uri.Uri.getFromQueryString(stateParam);
        var stateAbbreviation = GS.states.abbreviation(state);

        if (stateAbbreviation === undefined) {
            state = _(GS.uri.Uri.getPath().split('/')).filter(function(pathComponent) {
                return GS.states.isStateName(hyphensToSpaces(pathComponent));
            }).first();
            console.log('state name is ' + state);
            stateAbbreviation = GS.states.abbreviation(hyphensToSpaces(state));
        }

        return stateAbbreviation;
    };

    var schoolIdFromUrlPath = function() {
        var schoolId;
        var schoolPathRegex = /(\d+)-.+/;
        var schoolPathRegexPreK = /(\d+)/;
        var preschool = false;

        schoolId = _(GS.uri.Uri.getPath().split('/')).map(function(pathComponent) {
            if (pathComponent === 'preschools') {
                preschool = true;
            }
            var match = null;
            if (preschool) {
                match = schoolPathRegexPreK.exec(pathComponent);
            } else {
                match = schoolPathRegex.exec(pathComponent);
            }

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