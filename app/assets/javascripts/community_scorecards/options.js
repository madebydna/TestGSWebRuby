GS = GS || {};
GS.CommunityScorecards = GS.CommunityScorecards || {};
GS.CommunityScorecards.Options = function(options) {
  this.init(options);
};

GS.CommunityScorecards.Options.prototype = {

  validAttributes: [
    'breakdown', 'collectionId', 'dataType', 'grade', 'offset', 'sortType', 'data_sets'
  ],

  init: function(options) {
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
    if(this.isValidValue(value)) {
      this['_' + key] = value;
    }
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
  }

};
