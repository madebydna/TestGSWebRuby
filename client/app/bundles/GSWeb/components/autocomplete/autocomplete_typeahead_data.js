
//    var options = {
//        defaultUrl: string            required                      url that will get ajax request for data.
//        tokenizedAttribute: string    required
//        sortFunction: function        optional no default applied
//        rateLimitWait: int            optional but default applied  delay from keystroke to autocomplete. ex 100ms
//        displayLimit: int             optional but default applied  limit to how many results displayed
//        getFilterDataFunction: function  optional but default applied  filter dataset after queried.
//        dupDetectorFunction: function optional but default applied  duplicate detection and removal function
//        replaceUrlFunction: function  optional callback to          replace url dynamically right before ajax request
//    };
const init = function(options) { //options for init listed above
  let remote = {
    url: options['defaultUrl'],
    rateLimitWait: options['rateLimitWait'] || 100
  };
  let dataObject = {};
  let getDataObject = function() { return dataObject }; //gets redefined at the end of the function so that we can pass the constructed object to the filter
  options['getFilterDataFunction'] !== undefined ? remote.filter = options['getFilterDataFunction'].call(this, getDataObject) : remote.filter = getFilterDataFunction(getDataObject);
  options['replaceUrlFunction'] !== undefined ? remote.replace = options['replaceUrlFunction'] : null;

  let bloodhoundOptions = {
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace(options['tokenizedAttribute']),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    limit: options['displayLimit'] || 10,
    dupDetector: options['dupDetectorFunction'] || dupDetectorFunction,
    remote: remote
  };

  let sortFromOpt = options['sortFunction'];
  if (sortFromOpt === false) {
  } else if (sortFromOpt !== undefined) {
    bloodhoundOptions.sorter = sortFromOpt;
  } else {
    bloodhoundOptions.sorter = autocompleteSort;
  }

  dataObject = new Bloodhound(bloodhoundOptions);
  dataObject.tokenizedAttribute = options['tokenizedAttribute']; //for use later to set input value on display
  dataObject.initialize();
  return dataObject;
};

const dupDetectorFunction = function(remoteMatch, localMatch) {
  return remoteMatch.url == localMatch.url;
};

const getFilterDataFunction = function(getDataObject) {
  return (function(results) {
    let data = getDataObject();
    data.cacheList = data.cacheList || {};
    let cacheList = data.cacheList;
    for (let i = 0; i < results.length; i++) {
      if (cacheList[results[i].url] == null) {
        data.add(results[i]);
        cacheList[results[i].url] = true;
      }
    }
    return data.sorter(results); //even though sorter might not be added, Typeahead adds a sort method that returns the same array
  })
};

const autocompleteSort = function(obj1, obj2) {
  if (obj1.sort_order > obj2.sort_order)
    return -1;
  if (obj1.sort_order < obj2.sort_order)
    return 1;
  return 0;
};

export { init }
