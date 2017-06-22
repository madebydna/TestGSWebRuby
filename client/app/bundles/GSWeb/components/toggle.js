import checkRequiredProps from '../util/checkRequiredProps';
import log from '../util/log';

const Toggle = function($container) {
  this.$container = $container;
  this.targetSelector = ".js-toggle-target";
  this.buttonSelector = ".js-toggle-button";
  this.effect = "toggle";
  this.duration = "fast";
  this.open = false;
  this.callbacks = [];
  return this;
}

_.assign(Toggle.prototype, {
  $: jQuery,

  log: log,

  requiredProps: [
    '$container',
    'buttonSelector',
    'targetSelector'
  ],

  checkRequiredProps: checkRequiredProps,

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
      let html = this.$button().html();
      if(this.open) {
        html = html.replace(closed, open);
        this.$button().html(html);
      } else {
        html = html.replace(open, closed);
        this.$button().html(html);
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

  sendGoogleAnalyticsCallback: function sendGoogleAnalyticsCallback(category, label){
    return function() {
      var cat = this.$container.data(category);
      var lab = this.$container.data(label);
      if (this.open) {
        analyticsEvent(cat, 'Show More', lab);
      } else {
        analyticsEvent(cat, 'Show Less', lab);
      }
    }
  },

  init: function init() {
    this.checkRequiredProps();
    return this;
  }
});

export default Toggle;
