// TODO: change hardcoded asset
import Mappable from './mappable';

const District = function(){
  if (arguments.length) $.extend(this, arguments[0]);
  this.iconSize = 48;
  this.iconUrl = '/assets/icons/google_map_pins/120906-mapPins-district.png';
  this.strokeColor = '#2092C4';
  this.zIndex = 1;
  this.fillColor = 'rgba(0,0,0,0.2)';
  Mappable.apply(this, arguments);
};
District.prototype = $.extend(Mappable.prototype, {});
District.prototype.constructor = District;

export default District;
