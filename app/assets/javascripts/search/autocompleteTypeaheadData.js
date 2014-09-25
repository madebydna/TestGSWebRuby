GS.search = GS.search || {};

GS.search.autocomplete = GS.search.autocomplete || (function() {

//    var options = {
//        defaultUrl: 'string', required
//        tokenizedAttribute: 'string',  required
//        filterDataFunction: 'function', optional
//        replaceUrlFunction: 'function', optional callback to replace url dynamically
//        dupDetectorFunction: 'function', optional
//        rateLimitWait: 'int', optional
//        displayLimit: 'int', optional
//        sortFunction: 'function' optional
//    }; options for initializeData
    var initializeData = function(options) {
        var remote = {
            url: options['defaultUrl'],
            rateLimitWait: options['rateLimitWait'] || 100
        };
        var dataObject = {};
        var getDataObject = function() { return dataObject }; //gets redefined at the end of the function so that we can pass the constructed object to the filter
        options['filterDataFunction'] !== undefined ? remote.filter = options['filterDataFunction'](getDataObject) : remote.filter = filterDataFunction(getDataObject);
        options['replaceUrlFunction'] !== undefined ? remote.replace = options['replaceUrlFunction'] : null;

        var bloodhoundOptions = {
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace(options['tokenizedAttribute']),
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            limit: options['displayLimit'] || 10,
            dupDetector: options['dupDetectorFunction'] || dupDetectorFunction(),
            remote: remote
        };

        var sortFromOpt = options['sortFunction'];
        if (sortFromOpt === false) {
        } else if (sortFromOpt !== undefined) {
            bloodhoundOptions.sorter = sortFromOpt;
        } else {
            bloodhoundOptions.sorter = autocompleteSort();
        }

        dataObject = new Bloodhound(bloodhoundOptions);
        dataObject.initialize();
        return dataObject;
    };

    var dupDetectorFunction = function() {
        return (function(remoteMatch, localMatch) {
            return remoteMatch.url == localMatch.url;
        })
    };

    var filterDataFunction = function(getDataObject) {
        return (function(results) {
            var data = getDataObject();
            data.cacheList = data.cacheList || {};
            var cacheList = data.cacheList;
            for (var i = 0; i < results.length; i++) {
                if (cacheList[results[i].url] == null) {
                    data.add(results[i]);
                    cacheList[results[i].url] = true;
                }
            }
            return data.sorter(results); //even though sorter might not be added, Typeahead adds a sort method that returns the same array
        })
    };

    var autocompleteSort = function() {
        return (function(obj1, obj2) {
            if (obj1.sort_order > obj2.sort_order)
                return -1;
            if (obj1.sort_order < obj2.sort_order)
                return 1;
            return 0;
        })
    };

    return {
        initializeData: initializeData
    }
})();
