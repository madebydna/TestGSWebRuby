var GS = GS || {};

GS.states = (function(_) {
    var statesHash = {
     'alabama': 'al',
     'alaska': 'ak',
     'arizona': 'az',
     'arkansas': 'ar',
     'california': 'ca',
     'colorado': 'co',
     'connecticut': 'ct',
     'delaware': 'de',
     'district of columbia': 'dc',
     'florida': 'fl',
     'georgia': 'ga',
     'hawaii': 'hi',
     'idaho': 'id',
     'illinois': 'il',
     'indiana': 'in',
     'iowa': 'ia',
     'kansas': 'ks',
     'kentucky': 'ky',
     'louisiana': 'la',
     'maine': 'me',
     'maryland': 'md',
     'massachusetts': 'ma',
     'michigan': 'mi',
     'minnesota': 'mn',
     'mississippi': 'ms',
     'missouri': 'mo',
     'montana': 'mt',
     'nebraska': 'ne',
     'nevada': 'nv',
     'new hampshire': 'nh',
     'new jersey': 'nj',
     'new mexico': 'nm',
     'new york': 'ny',
     'north carolina': 'nc',
     'north dakota': 'nd',
     'ohio': 'oh',
     'oklahoma': 'ok',
     'oregon': 'or',
     'pennsylvania': 'pa',
     'rhode island': 'ri',
     'south carolina': 'sc',
     'south dakota': 'sd',
     'tennessee': 'tn',
     'texas': 'tx',
     'utah': 'ut',
     'vermont': 'vt',
     'virginia': 'va',
     'washington': 'wa',
     'west virginia': 'wv',
     'wisconsin': 'wi',
     'wyoming': 'wy'
    };

    var stateAbbreviations = _.values(statesHash);

    var encode = function(str) {
        return str.replace(/ /g, '-');
    };

    var decode = function(str) {
        return str.replace(/-/g, ' ');
    };

    var anyStateNameRegex = function() {
        var components = _(statesHash).keys().map(function(stateName) {
            return '^' + encode(stateName) + '$';
        });

        return new RegExp(components.join('|'), 'i');
    };

    var isStateName = function(str) {
        return anyStateNameRegex().test(str);
    };

    var abbreviation = function(str) {
        if (str === undefined) {
            return;
        }

        str = str.toLowerCase();

        if (str.length === 2 && _(stateAbbreviations).contains(str)) {
            return str;
        } else {
            return statesHash[ decode(str) ];
        }
    };

    return {
        anyStateNameRegex: anyStateNameRegex,
        isStateName: isStateName,
        abbreviation: abbreviation
    }

})(_);