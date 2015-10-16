// Augments GS to add extra methods for getting school and state from URL
// Requires: Lo-Dash

(function(GS, _) {
    "use strict";
    var stateParam = 'state';
    var schoolIdParam = 'schoolId';
    var schoolName

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
            stateAbbreviation = GS.states.abbreviation(hyphensToSpaces(state));
        }

        return stateAbbreviation;
    };

    var schoolIdFromUrlPath = function() {
        var schoolId;
        var schoolPathRegex = /(\d+)-.+/;
//        Regex to grab preschool ids by grabbing any path component that has only numeric digits
        var schoolPathRegexPreK = /([^a-zA-Z\-]+\d+[^a-zA-Z\-]+)/;
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

    var schoolNameFromUrlPath = function () {
        var schoolName;
        var schoolPathRegex = /\d+-(.+)/;
//        Regex to grab preschool Name
        var schoolPathRegexPreK = /preschools\/(.+?)\//;
        var preschool = false;
        schoolName = _(GS.uri.Uri.getPath().split('/')).map(function (pathComponent) {
            if (pathComponent === 'preschools') {
                preschool = true;
            }
            var match = null;
            match = schoolPathRegex.exec(pathComponent);
            return (match === null) ? null : match[1];
        }).compact().first();
        if (preschool) {

            var match = schoolPathRegexPreK.exec(GS.uri.Uri.getPath());
            schoolName = (match === null) ? null : match[1];

        }
        return schoolName === undefined ? undefined : schoolName.replace(/-/g,' ');
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
    GS.schoolNameFromUrl = schoolNameFromUrlPath;
})(GS, _);