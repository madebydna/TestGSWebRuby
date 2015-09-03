GS = GS || {};
GS.CommunityScorecards = GS.CommunityScorecards || {};
GS.CommunityScorecards.Options = function(options) {
  this.init(options);
};

GS.CommunityScorecards.Options.prototype = {

  validURLAttributes: ['sortBy', 'sortBreakdown', 'sortAscOrDesc'],
  validNonURLAttributes: ['collectionId', 'offset', 'highlightIndex', 'data_sets', 'gradeLevel'],

  init: function(options) {
    this.validAttributes = this.validNonURLAttributes.concat(this.validURLAttributes);
    _.each(this.validAttributes, function(attr) {
      if(attr in options) {
        this.set(attr, options[attr]);
      };
    }.gs_bind(this));
  },

  // Pair of weak getter/setter methods to try to force people to go through
  // isValidValue().
  get: function(key) {
    return this['_' + key];
  },

  set: function(key, value) {
    if(this.isValidValue(value) && value !== this.get(key)) {
      if (GS.util.isHistoryAPIAvailable() && _.contains(this.validURLAttributes, key)) {
        this.addToURL(key, value);
      }
      this['_' + key] = value;
      return true;
    }
    return false;
  },

  isValidValue: function(value) {
    // TODO Add real validation here
    return true;
  },

  to_h: function() {
    return _.object(this.validAttributes, this.value_map());
  },

  value_map: function () {
    return _.map(this.validAttributes, function(attr) {
      return this.get(attr);
    }.gs_bind(this));
  },

  addToURL: function(key, value){
    var data = History.getState()['data'];
    _.extend(data, GS.uri.Uri.getQueryData());
    data[key] = value;
    var queryParams = GS.uri.Uri.getQueryStringFromObject(data);
    History.replaceState(data, null, queryParams);
  },

};
