var GS = GS || {}
GS.components = GS.components || {};

GS.components.Toggle = GS.components.Toggle || function($container) {
  this.$container = $container;
  this.targetSelector = ".js-toggle-target";
  this.buttonSelector = ".js-toggle-button";
  this.effect = "toggle";
  this.duration = "fast";
  this.open = false;
  this.callbacks = [];
  return this;
}

GS.util = GS.util || {};

GS.util.checkRequiredProps = function() {
  if (!this.requiredProps) {
    return;
  }
  for(var i = 0; i < this.requiredProps.length; i++) {
    prop = this.requiredProps[i];
    if (!this.hasOwnProperty(prop) || this[prop] == undefined) {
      var error = prop + " is required but is undefined";
      this.log([error, this]);
      throw error;
      return;
    }
  }
  return this;
}

_.assign(GS.components.Toggle.prototype, {
  $: jQuery,

  log: GS.util.log,

  requiredProps: [
    '$container',
    'buttonSelector',
    'targetSelector'
  ],

  checkRequiredProps: GS.util.checkRequiredProps,

  $button: function $button() {
    return this.$container.find(this.buttonSelector);
  },

  $target: function $target() {
    return this.$container.find(this.targetSelector);
  },

  toggle: function toggle() {
    var target = this.$target();
    target[this.effect].call(target, this.duration, function() {
      this.open = !this.open;
      if(this.callbacks.length > 0) {
        for (var i = 0; i < this.callbacks.length; i++) {
          this.callbacks[i].call(this);
        }
      }
    }.bind(this));
  },

  add_onclick: function add_onclick() {
    this.$container.on(
      'click',
      this.buttonSelector,
      this.toggle.bind(this)
    );
    return this;
  },

  addCallback: function addCallback(callback) {
    this.callbacks.push(callback.bind(this));
    return this;
  },

  updateButtonTextCallback: function toggleButtonTextCallback(open, closed) {
    return function() {
      if(this.open) {
        this.$button().html(open);
      } else {
        this.$button().html(closed);
      }
    };
  },

  updateContainerClassCallback: function updateContainerClassCallback(open, closed) {
    return function() {
      if(this.open) {
        this.$container.addClass(open);
        this.$container.removeClass(closed);
      } else {
        this.$container.addClass(closed);
        this.$container.removeClass(open);
      }
    };
  },

  init: function init() {
    this.checkRequiredProps();
    return this;
  }
});

GS.components.makeDrawer = function($container) {
  var toggle = _.assign(new GS.components.Toggle($container));
  toggle.effect = "slideToggle";
  toggle.addCallback(
    toggle.updateButtonTextCallback('Show Less', 'Show More')
  );
  toggle.addCallback(
    toggle.updateContainerClassCallback('show-more--open','show-more--closed')
  );
  return toggle.init();
}

GS.components.makeDrawersWithSelector = function(selector) {
  $(selector).each(function() {
    GS.components.makeDrawer($(this)).add_onclick();
  });
};

$(function() {
  GS.components.makeDrawersWithSelector($('.js-drawer'));
});
